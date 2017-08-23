defmodule NervesAps.Monitor.Loop do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work(30_000)
    {:ok, state}
  end

  @way_back_when ~N[1980-01-01 00:00:00]
  def handle_info(:loop, state) do
    # Logger.warn "Checking system time"

    case set_system_time_from_pump(Timex.before?(Timex.now, @way_back_when)) do
      {:ok} ->
        NervesAps.Monitor.NightscoutEntriesReporter.loop()
        NervesAps.Monitor.NightscoutTreatmentsReporter.loop()
        NervesAps.Monitor.CurrentBasalMonitor.loop()
      {:error, error} ->
        Logger.error("Unable to set system time: #{inspect(error)}")
    end

    schedule_work()
    {:noreply, state}
  end

  @after_period 5 * 60 * 1000 # 5 minutes
  defp schedule_work(after_period \\ @after_period) do
    Process.send_after(self(), :loop, after_period)
  end

  defp set_system_time_from_pump(false), do: {:ok}
  defp set_system_time_from_pump(true) do
    with {:ok, pump_time} <- Pummpcomm.Session.Pump.read_time(),
         utc_zoned_time <- Timex.to_datetime(pump_time, :local) |> Timex.Timezone.convert(:utc),
         {:ok, formatted_time} <- Timex.format(utc_zoned_time, "%Y-%m-%d %H:%M:%S", :strftime) do
      Logger.warn "Setting system time from pump to #{formatted_time} (UTC)"
      System.cmd("date", ["-s", formatted_time])
      {:ok}
    else
      error -> {:error, error}
    end
  end
end
