use Mix.Config

config :logger, level: :debug
config :cfg, NervesAps.Configuration,
  file: "#{File.cwd!}/../host_config.json"

config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake

config :ui, NervesAps.UI.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  secret_key_base: "9w9MI64d1L8mjw+tzTmS3qgJTJqYNGJ1dNfn4S/Zm6BbKAmo2vAyVW7CgfI3CpII",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: NervesAps.UI.PubSub,
           adapter: Phoenix.PubSub.PG2]
