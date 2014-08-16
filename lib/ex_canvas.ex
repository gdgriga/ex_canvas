import Logger

defmodule ExCanvas do
  import Plug.Conn
  use Plug.Router

  plug Plug.Static, at: "/", from: :ex_canvas
  plug :match
  plug :dispatch

  def init(opts) do
    Agent.start(fn -> HashSet.new end, name: :clients)
    opts
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
    send_resp(conn, 404, "not found")
  end
end

info("Running on http://localhost:4000")
Plug.Adapters.Cowboy.http ExCanvas, []
