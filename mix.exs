defmodule Spherical.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :spherical,
     name: "Spherical",
     version: @version,
     elixir: "~> 1.0",
     package: package,
     docs: [source_ref: "v#{@version}", main: "Spherical"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     source_url: "https://github.com/arpunk/spherical",
     homepage_url: "http://github.com/arpunk/spherical",
     description: description]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.8", only: :docs},
     {:earmark, "~> 0.1", only: :docs}]
  end

  def description do
    """
    An spherical geometry library for Elixir
    """
  end

  defp package do
    [contributors: ["Ricardo Lanziano"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/arpunk/spherical"},
     files: ~w(lib CHANGELOG.md LICENSE mix.exs README.md) ++
       ~w(test/shared)]
  end
end
