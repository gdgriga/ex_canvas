import Logger

defmodule ExCanvasClient do
  def send(msg) do
    Node.start(:client, :shortnames)
    Node.set_cookie(:ex_canvas_cookie)
    server = :server@hal9013
    IO.inspect(Node.ping(server))  # optional
    send({:ex_canvas_say, server}, {:data, [x: 10, y: 30, text: msg]})
  end
end
