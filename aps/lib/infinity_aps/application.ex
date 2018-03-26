defmodule InfinityAPS.Application do
  @moduledoc false

  use Application
  require Logger

  alias InfinityAPS.Configuration
  alias InfinityAPS.Monitor.Loop
  alias InfinityAPS.Oref0.{Entries, LoopStatus}
  alias InfinityAPS.PummpcommSupervisor
  alias Pummpcomm.Radio.ChipSupervisor

  @timeout 30_000

  def start(_type, _args) do
    start_twilight_informant()

    opts = [strategy: :one_for_one, name: InfinityAPS.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  defp children do
    [
      ChipSupervisor.child_spec([]),
      PummpcommSupervisor.child_spec([]),
      Loop.child_spec([]),
      LoopStatus.child_spec(loop_directory: Application.get_env(:aps, :loop_directory)),
      Entries.child_spec([])
    ]

    # children ++ [ChipSupervisor.child_spec([])]
  end

  defp start_twilight_informant do
    Application.put_env(:twilight_informant, :ns_url, Configuration.get_config(:nightscout_url))

    Application.put_env(
      :twilight_informant,
      :api_secret,
      Configuration.get_config(:nightscout_token)
    )

    Application.put_env(
      :twilight_informant,
      :httpoison_opts,
      timeout: @timeout,
      recv_timeout: @timeout
    )

    TwilightInformant.Configuration.start(nil, nil)
  end
end

defmodule InfinityAPS.PummpcommSupervisor do
  @moduledoc false
  use Supervisor

  alias InfinityAPS.Configuration

  def start_link(arg) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    [:cgm, :pump]
    |> Enum.uniq()
    |> Enum.each(fn provider ->
      Supervisor.start_child(
        sup,
        worker(Application.get_env(:pummpcomm, provider), [
          Configuration.get_config(:pump_serial),
          Configuration.local_timezone()
        ])
      )
    end)
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end
end
