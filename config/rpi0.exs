use Mix.Config

config :logger, level: :debug
config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, Pummpcomm.Driver.SubgRfspy.UART, device: "/dev/ttyAMA0"
config :pummpcomm, Pummpcomm.Session.Pump, pump_serial: "123456"

config :nerves_network,
  regulatory_domain: "US"

config :nerves, :firmware,
  rootfs_additions: "rootfs-additions"

config :bootloader,
  init: [:nerves_init_gadget],
  app: :zero

config :nerves_firmware_ssh,
  authorized_keys: ["""
  ssh-rsa LOTSOFEXCITINGKEYSTUFFHERE
  """]

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"
