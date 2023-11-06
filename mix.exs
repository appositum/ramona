defmodule Ramona.MixProject do
  use Mix.Project

  def project do
    [
      app: :ramona,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Ramona, []}
    ]
  end

  defp deps do
    [
      {:css_colors, "~> 0.2.0"},
      {:mogrify_draw, "~> 0.1.0"},
      {:floki, "~> 0.20.0"},
      {:alchemy, github: "appositum/alchemy", branch: "development"}
    ]
  end
end
