use Mix.Config

config :logger, level: :debug

config :cfg, InfinityAPS.Configuration,
  file: "#{File.cwd!}/../host_root/host_config.json"

config :infinity_aps,
  loop_directory: "#{File.cwd!}/../host_root/loop",
  node_modules_directory: "#{File.cwd!}/../host_root/node_modules",
  host_mode: true

config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake

config :ui, InfinityAPS.UI.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  secret_key_base: "9w9MI64d1L8mjw+tzTmS3qgJTJqYNGJ1dNfn4S/Zm6BbKAmo2vAyVW7CgfI3CpII",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: InfinityAPS.UI.PubSub,
           adapter: Phoenix.PubSub.PG2]
