import Logger

defmodule ExCanvas do
  import Plug.Conn
  use Plug.Router

  plug Plug.Static, at: "/", from: :ex_canvas
  plug :match
  plug :dispatch

  def main do
    Plug.Adapters.Cowboy.http(ExCanvas, [])
  end

  def init(opts) do
    Agent.start(fn -> HashSet.new end, name: :clients)
    Process.register(spawn(&client_cast/0), :ex_canvas_say)
    System.cmd("epmd", ["-daemon"])
    case Node.start(:server, :shortnames) do
      {:ok, pid} -> info("Started distributed node.")
      {:error, term} -> error("Failed to start. Is `epmd -daemon` running?")
    end
    Node.set_cookie(:ex_canvas_cookie)
    info("Running on http://localhost:4000")
    opts
  end

  defp client_cast do
    receive do
      {:data, data} ->
        json = :jsx.encode(data)
        clients = Agent.get(:clients, fn id -> id end)
        debug("Sending to #{Enum.count(clients)} client(s): #{json}")
        Enum.each(clients, &send(&1, {:json, json}))
        client_cast
      _ -> :ok
    end
  end

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, "priv/index.html")
  end

  get "/events" do
    pid = self()
    Agent.update(:clients, &Set.put(&1, pid))
    count = Agent.get(:clients, &Enum.count(&1))
    debug("Connected: #{count} client(s)")
    conn
    |> put_resp_content_type("text/event-stream")
    |> send_chunked(200)
    |> canvas_loop
  end

  defp canvas_loop(conn) do
    receive do
      {:json, json} ->
        case chunk(conn, "data: #{json}\n\n") do
          {:ok, conn} -> canvas_loop(conn)
          _ -> debug("Failed to send: #{json}"); disconnect(); conn
        end
    end
  end

  defp disconnect do
    pid = self()
    Agent.update(:clients, &Set.delete(&1, pid))
  end

  match _ do
    send_resp(conn, 404, "not found\n")
  end
end
