defmodule InfinityAPS.Application do
  @moduledoc false

  use Application
  require Logger

  alias InfinityAPS.Configuration.Server
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
      InfinityAPS.PummpcommSupervisor.child_spec([]),
      InfinityAPS.Monitor.Loop.child_spec([]),
      InfinityAPS.Oref0.LoopStatus.child_spec(
        loop_directory: Application.get_env(:aps, :loop_directory)
      ),
      InfinityAPS.Oref0.Entries.child_spec([])
    ]

    # children ++ [ChipSupervisor.child_spec([])]
  end

  defp start_twilight_informant do
    Application.put_env(:twilight_informant, :ns_url, Server.get_config(:nightscout_url))
    Application.put_env(:twilight_informant, :api_secret, Server.get_config(:nightscout_token))

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
    |> Enum.each(fn provider ->
      Supervisor.start_child(
        sup,
        worker(Application.get_env(:pummpcomm, provider), [
          Server.get_config(:pump_serial),
          local_timezone()
        ])
      )
    end)
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end

  defp local_timezone do
    Server.get_config(:timezone) |> Timex.Timezone.get()
  end
end
