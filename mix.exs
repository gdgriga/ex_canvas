defmodule ExCanvas.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_canvas,
     version: "0.0.1",
     elixir: "~> 0.15.1",
     deps: deps,
     aliases: aliases]
  end

  def application do
    [applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 0.5.3"},
     {:jsx, "~> 2.0.4"}]
  end

  defp aliases do
    [r: "run --no-halt -e ExCanvas.main",
     c: "run -e ExCanvasClient.send(:test)"]
  end
end
