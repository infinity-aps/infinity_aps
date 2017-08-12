use Mix.Config

config :logger, level: :debug

config :cfg, NervesAps.Configuration,
  file: "/root/nerves_aps.json"

config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump

config :nerves_network,
  regulatory_domain: "US"

config :nerves, :firmware,
  rootfs_additions: "rootfs-additions"

config :bootloader,
  init: [:nerves_init_gadget],
  app: :zero

import_config "config.priv.exs"
