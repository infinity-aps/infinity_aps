use Mix.Config

config :logger, :console, format: "[$level] $message\n"


config :aps,
  loop_directory: Path.expand("../host_root/loop"),
  node_modules_directory: Path.expand("../host_root/node_modules")

config :aps, InfinityAPS.Configuration, file: Path.expand("../host_root/host_config.json")

config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake

if File.exists?("#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
