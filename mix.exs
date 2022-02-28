defmodule Ramona.MixProject do
  use Mix.Project

  def project do
    [
      app: :ramona,
      version: "0.1.8",
      elixir: "~> 1.10",
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
      {:css_colors, "~> 0.2.2"},
      {:floki, "~> 0.32.0"},
      {:html_entities, "~> 0.5"},
      {:mogrify_draw, "~> 0.1.1"},
      {:poison, "~> 4.0.1"},
      {:cowsay, github: "bbrock25/cowsay"},
      {:alchemy, github: "appositum/alchemy", branch: "own"}
    ]
  end
end
