import Logger

defmodule ExCanvasClient do
  def send(msg) do
    Node.start(:client, :shortnames)
    Node.set_cookie(:ex_canvas_cookie)
    # :server@hostname
    server = List.to_atom('server@' ++ case :inet.gethostname do
      {:ok, hostname} -> hostname
    end)
    IO.inspect(Node.ping(server))  # optional
    send({:ex_canvas_say, server}, {:data, [x: 10, y: 30, text: msg]})
  end
end
