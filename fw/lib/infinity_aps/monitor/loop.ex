defmodule InfinityAPS.Monitor.Loop do
  use GenServer
  require Logger

  alias InfinityAPS.Configuration.Server

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(_) do
    schedule_work(5_000)
    {:ok, %{}}
  end

  @way_back_when ~N[1980-01-01 00:00:00]
  def handle_info(:loop, state) do
    # Logger.warn "Checking system time"

    case set_system_time_from_pump(Timex.before?(Timex.now, @way_back_when)) do
      {:ok} ->
        InfinityAPS.Monitor.NightscoutEntriesReporter.loop(local_timezone())
        # InfinityAPS.Monitor.PumpHistoryMonitor.loop(local_timezone())
        # InfinityAPS.Monitor.CurrentBasalMonitor.loop()
        # InfinityAPS.Monitor.ProfileMonitor.loop()
        # InfinityAPS.Monitor.IOBMonitor.loop(local_timezone())
        # InfinityAPS.Monitor.DetermineBasal.loop()
        # InfinityAPS.Monitor.EnactTempBasal.loop()
        InfinityAPS.Monitor.NightscoutTreatmentsReporter.loop(local_timezone())
        schedule_work()
      {:error, error} ->
        Logger.error("Unable to set system time: #{inspect(error)}")
        schedule_work(30_000)
    end

    {:noreply, state}
  end

  @after_period 4 * 60 * 1000 # 4 minutes
  defp schedule_work(after_period \\ @after_period) do
    Process.send_after(self(), :loop, after_period)
  end

  defp set_system_time_from_pump(false), do: {:ok}
  defp set_system_time_from_pump(true) do
    with {:ok, pump_time} <- Pummpcomm.Session.Pump.read_time(),
         utc_zoned_time <- Timex.to_datetime(pump_time, local_timezone()) |> Timex.Timezone.convert(:utc),
         {:ok, formatted_time} <- Timex.format(utc_zoned_time, "%Y-%m-%d %H:%M:%S", :strftime) do
      Logger.warn "Setting system time from pump to #{formatted_time} (UTC)"
      System.cmd("date", ["-s", formatted_time])
      {:ok}
    else
      error -> {:error, error}
    end
  end

  defp local_timezone do
    Server.get_config(:timezone) |> Timex.Timezone.get()
  end
end
