defmodule InfinityAPS.Application do
  use Application
  require Logger
  alias InfinityAPS.Configuration.Server
  alias Pummpcomm.Radio.ChipSupervisor
  alias Phoenix.PubSub.PG2

  def start(_type, _args) do
    unless host_mode() do
      init_network()
    end

    opts = [strategy: :one_for_one, name: InfinityAPS.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  defp children do
    children = [
      InfinityAPS.PummpcommSupervisor.child_spec([]),
      InfinityAPS.Monitor.Loop.child_spec([]),
      Supervisor.child_spec(PG2, start: {PG2, :start_link, [Nerves.PubSub, [poolsize: 1]]})
    ]

    case host_mode() do
      true ->
        children
      false ->
        children ++ [ChipSupervisor.child_spec([])]
    end
  end

  defp host_mode do
    Application.get_env(:infinity_aps, :host_mode)
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

defmodule InfinityAPS.PummpcommSupervisor do
  use Supervisor
  alias InfinityAPS.Configuration.Server

  def start_link(arg) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    [:cgm, :pump]
    |> Enum.uniq()
    |> Enum.each(fn(provider) ->
      Supervisor.start_child(sup, worker(Application.get_env(:pummpcomm, provider), [Server.get_config(:pump_serial), local_timezone()]))
    end)
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end

  defp local_timezone do
    Server.get_config(:timezone) |> Timex.Timezone.get()
  end
end
