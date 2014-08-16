import Logger

defmodule ExCanvas do
  import Plug.Conn
  use Plug.Router

  plug Plug.Static, at: "/", from: :ex_canvas
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, "priv/index.html")
  end

  get "/events" do
    conn
    |> put_resp_content_type("text/event-stream")
    |> send_chunked(200)
    |> send_events
  end

  defp send_events(conn) do
    pid = spawn(fn -> canvas_loop(conn) end)
    send(pid, {:data, "-1hello"})
    send(pid, {:data, "-2hello"})
    send(pid, {:data, "-3hello"})
    conn
  end

  defp canvas_loop(conn) do
    receive do
      {:data, data} ->
        case chunk(conn, ["data: ", data, "\n\n"]) do
          {:ok, conn} -> canvas_loop(conn)
          _ -> debug("failed to send chunk: " <> data)
        end
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end

info("Running on http://localhost:4000")
Plug.Adapters.Cowboy.http ExCanvas, []
