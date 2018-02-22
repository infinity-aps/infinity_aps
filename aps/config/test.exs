use Mix.Config

config :logger, :console, format: "[$level] $message\n"

config :cfg, InfinityAPS.Configuration,
  file: "#{File.cwd!}/../host_root/host_config.json"

config :infinity_aps,
  loop_directory: "#{File.cwd!}/../host_root/loop",
  host_mode: true

config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake
