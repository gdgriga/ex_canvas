import Logger

defmodule ExCanvas do
  import Plug.Conn
  use Plug.Router

  plug Plug.Static, at: "/", from: :ex_canvas
  plug :match
  plug :dispatch

  def init(opts) do
    Agent.start(fn -> HashSet.new end, name: :clients)
    Process.register(spawn(&say/0), :ex_canvas_say)  # send({:ex_canvas_say, Node}, msg)
    info("Running on http://localhost:4000")
    opts
  end

  defp say do
    receive do
      msg ->
        Agent.cast(:clients, &Enum.each(&1, fn client_pid -> send(client_pid, msg) end))
        say
    end
  end

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, "priv/index.html")
  end

  get "/events" do
    Agent.update(:clients, &Set.put(&1, self()))
    conn = conn
    |> put_resp_content_type("text/event-stream")
    |> send_chunked(200)

    json = :jsx.encode([x: 50, y: 50, text: "hello"])
    chunk(conn, ["data: ", json, "\n\n"])

    json = :jsx.encode([x: 70, y: 100, text: "world"])
    chunk(conn, ["data: ", json, "\n\n"])

    canvas_loop(conn)
  end

  put "/say" do
    {msg, conn} = case read_body(conn) do
      {:ok, msg, conn}   -> {msg, conn}
      {:more, msg, conn} -> {"#{msg}...", conn}
      {:error, reason}   -> {"error: #{reason}", conn}
    end
    debug("/say read: '#{msg}'")
    send(:ex_canvas_say, msg)
    send_resp(conn, 201, "message queued\n")
  end

  defp canvas_loop(conn) do
    receive do
      {:data, data} ->
        json = :jsx.encode(data)
        case chunk(conn, ["data: ", json, "\n\n"]) do
          {:ok, conn} -> canvas_loop(conn)
          _ -> debug("Failed to send event: " <> json); conn
        end
    end
  end

  match _ do
    send_resp(conn, 404, "not found\n")
  end
end

Plug.Adapters.Cowboy.http ExCanvas, []
