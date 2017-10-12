defmodule InfinityAPS.Application do
  use Application
  require Logger
  alias InfinityAPS.Configuration.Server
  alias SubgRfspy

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(InfinityAPS.PummpcommSupervisor, []),
      worker(InfinityAPS.Monitor.Loop, []),
      supervisor(Phoenix.PubSub.PG2, [Nerves.PubSub, [poolsize: 1]])
    ]

    if !Application.get_env(:infinity_aps, :host_mode) do
      init_network()
    end

    opts = [strategy: :one_for_one, name: InfinityAPS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @key_mgmt :"WPA-PSK"
  defp init_network() do
    Logger.info fn() -> "Initializing Network" end
    ssid = Server.get_config(:wifi_ssid)
    psk = Server.get_config(:wifi_psk)
    Nerves.Network.setup "wlan0", ssid: ssid, psk: psk, key_mgmt: @key_mgmt
  end
end

defmodule InfinityAPS.PummpcommSupervisor do
  use Supervisor
  alias InfinityAPS.Configuration.Server

  def start_link() do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    Supervisor.start_child(sup, worker(SubgRfspy.UART, [Server.get_config(:subg_rfspy_device)]))
    Supervisor.start_child(sup, worker(Pummpcomm.Session.Pump, [Server.get_config(:pump_serial)]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end
