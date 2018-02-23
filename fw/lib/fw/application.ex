defmodule Fw.Application do
  use Application
  require Logger
  alias InfinityAPS.Configuration.Server
  alias Phoenix.PubSub.PG2

  def start(_type, _args) do
    unless host_mode() do
      init_network()
    end

    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  defp children do
    [
      Supervisor.child_spec(PG2, start: {PG2, :start_link, [Nerves.PubSub, [poolsize: 1]]}),
    ]
  end

  defp host_mode do
    Application.get_env(:fw, :host_mode)
  end

  @key_mgmt :"WPA-PSK"
  defp init_network() do
    Logger.info fn() -> "Initializing Network" end
    ssid = Server.get_config(:wifi_ssid)
    psk = Server.get_config(:wifi_psk)
    case psk || "" do
      "" -> Nerves.Network.setup "wlan0", ssid: ssid, key_mgmt: :"NONE"
      _ -> Nerves.Network.setup "wlan0", ssid: ssid, psk: psk, key_mgmt: @key_mgmt
    end
  end
end
