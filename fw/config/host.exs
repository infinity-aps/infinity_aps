use Mix.Config

config :logger, level: :debug
config :cfg, NervesAps.Configuration,
  file: "#{File.cwd!}/../host_config.json"

config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, Pummpcomm.Driver.SubgRfspy.UART, device: "/dev/tty.usbserial-00001014"
config :pummpcomm, Pummpcomm.Session.Pump, pump_serial: "856188"
