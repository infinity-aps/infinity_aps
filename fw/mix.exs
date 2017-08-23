defmodule NervesAps.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell.info([:green, """
  Mix environment
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])

  def project do
    [app: :nerves_aps,
     version: "0.1.0",
     elixir: "~> 1.4.0",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.4"],
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
    [mod: {NervesAps.Application, []},
     extra_applications: [:logger]]
  end

  def deps do
    [{:nerves, "~> 0.6", runtime: false},
     {:pummpcomm, "~> 2.1.1"},
     {:twilight_informant, path: "/Users/tmecklem/src/t1d/diy-pancreas/twilight_informant"},
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
