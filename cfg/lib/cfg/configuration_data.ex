defmodule InfinityAPS.Configuration.ConfigurationData do
  alias InfinityAPS.Configuration.Preferences

  defstruct pump_serial: nil,
    subg_rfspy_device: nil,

    wifi_ssid: nil,
    wifi_psk: nil,

    nightscout_url: nil,
    nightscout_token: nil,
    preferences: %Preferences{}
end
