defmodule ExCanvas.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_canvas,
     version: "0.0.1",
     elixir: "~> 0.15.1",
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 0.5.3"}]
  end
end
