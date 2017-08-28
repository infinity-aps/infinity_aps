use Mix.Config

config :logger, level: :debug

config :cfg, InfinityAPS.Configuration,
  file: "/root/infinity_aps.json"

config :infinity_aps,
  loop_directory: "/root/loop",
  host_mode: false

config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.Pump

config :nerves_network,
  regulatory_domain: "US"

config :nerves, :firmware,
  rootfs_additions: "rootfs-additions"

config :bootloader,
  init: [:nerves_init_gadget],
  app: :zero

config :ui, InfinityAPS.UI.Endpoint,
  http: [port: 80],
  url: [host: "localhost", port: 80],
  secret_key_base: "9w9MI64d1L8mjw+tzTmS3qgJTJqYNGJ1dNfn4S/Zm6BbKAmo2vAyVW7CgfI3CpII",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: InfinityAPS.UI.PubSub,
           adapter: Phoenix.PubSub.PG2]

import_config "config.priv.exs"
