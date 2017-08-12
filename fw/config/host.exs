use Mix.Config

config :logger, level: :debug
config :cfg, NervesAps.Configuration,
  file: "#{File.cwd!}/../host_config.json"

config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
