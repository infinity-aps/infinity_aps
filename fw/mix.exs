defmodule InfinityAPS.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell.info([:green, """
  Mix environment
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])

  def project do
    [app: :infinity_aps,
     version: "0.1.0",
     elixir: "~> 1.4.0",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.6.1"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     lockfile: "mix.lock.#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(@target),
     deps: deps()]
  end

  def application, do: application(@target)

  def application("host") do
    [extra_applications: [:logger]]
  end
  def application(_target) do
    [mod: {InfinityAPS.Application, []},
     extra_applications: [:logger]]
  end

  def deps do
    [{:nerves, "~> 0.6", runtime: false},
     {:pummpcomm, "~> 2.1.3"},
     {:twilight_informant, github: "infinity-aps/twilight_informant"},
     {:poison, "~> 3.1"},
     {:timex, "~> 3.0"},
     {:cfg, path: "../cfg"},
     {:ui, path: "../ui"}] ++
    deps(@target)
  end

  def deps("host"), do: []
  def deps(target) do
    [ system(target),
      {:bootloader, "~> 0.1"},
      {:nerves_runtime, "~> 0.4"},
      {:nerves_init_gadget, github: "fhunleth/nerves_init_gadget"}
    ]
  end

  def system("infinity_rpi0"), do: {:infinity_system_rpi0, ">= 0.0.0", github: "infinity-aps/infinity_system_rpi0", tag: "v0.17.0", runtime: false}
  def system("rpi"), do: {:nerves_system_rpi, ">= 0.0.0", runtime: false}
  def system("rpi0"), do: {:nerves_system_rpi0, ">= 0.0.0", runtime: false}
  def system("rpi2"), do: {:nerves_system_rpi2, ">= 0.0.0", runtime: false}
  def system("rpi3"), do: {:nerves_system_rpi3, ">= 0.0.0", runtime: false}
  def system("bbb"), do: {:nerves_system_bbb, ">= 0.0.0", runtime: false}
  def system("linkit"), do: {:nerves_system_linkit, ">= 0.0.0", runtime: false}
  def system("ev3"), do: {:nerves_system_ev3, ">= 0.0.0", runtime: false}
  def system("qemu_arm"), do: {:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}
  def system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  def aliases("host"), do: []
  def aliases(_target) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
