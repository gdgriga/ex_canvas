defmodule ExCanvasClient do

  def main do
    Node.start(:demo_client, :shortnames)
    Node.set_cookie(:ex_canvas_cookie)

    {:ok, hostname} = :inet.gethostname
    server = List.to_atom('server@' ++ hostname)
    dest = {:ex_canvas_say, server}
    draw(dest)
  end

  def draw(dest) do
    rr = 150.0
    r = 50.0
    pi = :math.pi()
    is = 100

    for ui <- 0..(is - 1) do
      for ti <- 0..(is - 1) do
        u = (ui / is * 2 + 1) * pi
        t = ti / is * 2 * pi
        x = (rr + r * :math.cos(u)) * :math.sin(t)
        y = (rr + r * :math.cos(u)) * :math.cos(t)
        z = r * :math.sin(u)
        c1 = round(x * 2 / (rr + r) * -255)
        c2 = round(y * 2 / (rr + r) * 255)
        ca = (z + r) / r / 2
        color = "rgba(255,#{c1},#{c2},#{ca})"
        pixel3d(dest, x, y, z, color)
      end
    end

    text(dest, 220, 220, "HELLO TORUS", "#fff")
  end

  defp pixel(dest, x, y, color) do
    send(dest, {:data, [:pixel, [x, y, color]]});
  end

  defp pixel3d(dest, x, y, z, color) do
    xx = 640 / 2 + (x - y) * :math.sqrt(3) / 2
    yy = 480 / 2 - z + x / 2 + y / 2
    pixel(dest, xx, yy, color)
  end

  defp text(dest, x, y, text, color) do
    send(dest, {:data, [:text, [x, y, text, color]]});
  end

end
