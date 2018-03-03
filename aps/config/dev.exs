use Mix.Config

config :logger, :console, format: "[$level] $message\n"

config :cfg, InfinityAPS.Configuration, file: "#{File.cwd!()}/../host_root/host_config.json"

config :aps,
  loop_directory: Path.expand("../host_root/loop", File.cwd!()),
  host_mode: true

config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake
