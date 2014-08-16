import Logger

defmodule ExCanvasClient do
  def send(msg) do
    Node.start(:client, :shortnames)
    Node.set_cookie(:ex_canvas_cookie)
    server = :server@localhost
    IO.inspect(Node.ping(server))  # optional
    send({:ex_canvas_say, server}, msg)
  end
end
