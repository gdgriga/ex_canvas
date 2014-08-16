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

  match _ do
    send_resp(conn, 404, "not found")
  end
end

IO.puts "Running on http://localhost:4000"
Plug.Adapters.Cowboy.http ExCanvas, []
