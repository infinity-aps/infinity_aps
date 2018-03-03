defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell.info([:green, """
  Mix environment
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])

  def project do
    [app: :fw,
     version: "0.1.0",
     elixir: "~> 1.6",
     target: @target,
     archives: [nerves_bootstrap: "~> 1.0-rc"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     lockfile: "mix.lock.#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application, do: application(@target)

  def application(target) do
    [mod: {Fw.Application, []},
     env: [target: target],
     extra_applications: [:logger]]
  end

  def deps do
    [{:nerves, "~> 1.0-rc", runtime: false},
     {:poison, "~> 3.1"},
     {:timex, "~> 3.0"},
     {:cfg, path: "../cfg"},
     {:aps, path: "../aps"},
     {:ui, path: "../ui"}] ++
    deps(@target)
  end

  def deps("host") do
    [{:phoenix_live_reload, "~> 1.1"},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5.1", only: :test, runtime: false}]
  end

  def deps(target) do
    [system(target),
     {:shoehorn, "~> 0.2"},
     {:nerves_runtime, "~> 0.5"},
     {:nerves_init_gadget, github: "nerves-project/nerves_init_gadget", ref: "dhcp"}]
  end

  def system("infinity_rpi0"), do: {:infinity_system_rpi0, ">= 0.0.0", github: "infinity-aps/infinity_system_rpi0", ref: "v1.0.0-rc.0", runtime: false}
  def system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  defp aliases, do: aliases(@target)
  def aliases("host"), do: []
  def aliases(_target) do
    ["compile": "compile --warnings-as-errors",
     "loadconfig": [&bootstrap/1]]
  end

  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end
end
