defmodule InfinityAPS.Configuration.ConfigurationData do
  alias InfinityAPS.Configuration.Preferences

  defstruct timezone: nil,
            pump_serial: nil,
            wifi_ssid: nil,
            wifi_psk: nil,
            nightscout_url: nil,
            nightscout_token: nil,
            preferences: %Preferences{}
end
