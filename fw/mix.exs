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
     elixir: "~> 1.5",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.6.1"],
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
    [{:nerves, "~> 0.7", runtime: false},
     {:poison, "~> 3.1"},
     {:timex, "~> 3.0"},
     {:cfg, path: "../cfg"},
     {:aps, path: "../aps"},
     {:ui, path: "../ui"}] ++
    deps(@target)
  end

  def deps("host") do
    [{:phoenix_live_reload, "~> 1.1"}]
  end

  def deps(target) do
    [ system(target),
      {:bootloader, "~> 0.1"},
      {:nerves_runtime, "~> 0.5"},
      {:nerves_init_gadget, github: "nerves-project/nerves_init_gadget", ref: "dhcp"}
    ]
  end

  def system("infinity_rpi0"), do: {:infinity_system_rpi0, ">= 0.0.0", github: "infinity-aps/infinity_system_rpi0", branch: "rel-v0.18.2", runtime: false}
  def system("rpi"), do: {:nerves_system_rpi, ">= 0.0.0", runtime: false}
  def system("rpi0"), do: {:nerves_system_rpi0, ">= 0.0.0", runtime: false}
  def system("rpi2"), do: {:nerves_system_rpi2, ">= 0.0.0", runtime: false}
  def system("rpi3"), do: {:nerves_system_rpi3, ">= 0.0.0", runtime: false}
  def system("bbb"), do: {:nerves_system_bbb, ">= 0.0.0", runtime: false}
  def system("linkit"), do: {:nerves_system_linkit, ">= 0.0.0", runtime: false}
  def system("ev3"), do: {:nerves_system_ev3, ">= 0.0.0", runtime: false}
  def system("qemu_arm"), do: {:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}
  def system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  defp aliases, do: aliases(@target)
  def aliases("host"), do: []
  def aliases(_target) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"],
     "compile": "compile --warnings-as-errors"]
  end
end
