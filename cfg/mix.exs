defmodule InfinityAPS.Configuration.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cfg,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {InfinityAPS.Configuration.Application, []}]
  end

  defp deps do
    [{:poison, "~> 3.1"}]
  end
end
