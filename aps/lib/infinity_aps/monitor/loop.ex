defmodule InfinityAPS.Monitor.Loop do
  @moduledoc false
  use GenServer
  require Logger

  alias InfinityAPS.Configuration

  alias InfinityAPS.Monitor.{
    GlucoseMonitor,
    PumpHistoryMonitor,
    CurrentBasalMonitor,
    ProfileMonitor,
    IOBMonitor,
    DetermineBasal,
    EnactTempBasal,
    NightscoutTreatmentsReporter
  }

  alias InfinityAPS.Oref0.LoopStatus
  alias Timex.Timezone

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(_) do
    schedule_work(5_000)
    {:ok, %{}}
  end

  @way_back_when ~N[1980-01-01 00:00:00]
  def handle_info(:loop, state) do
    case set_system_time_from_pump(Timex.before?(Timex.now(), @way_back_when)) do
      {:ok} ->
        local_timezone = Configuration.local_timezone()
        GlucoseMonitor.loop(local_timezone)
        PumpHistoryMonitor.loop(local_timezone)
        CurrentBasalMonitor.loop()
        ProfileMonitor.loop(local_timezone)
        IOBMonitor.loop(local_timezone)
        DetermineBasal.loop()
        LoopStatus.update_status_from_disk()
        EnactTempBasal.loop()
        NightscoutTreatmentsReporter.loop(local_timezone)
        schedule_work()

      {:error, error} ->
        Logger.error("Unable to set system time: #{inspect(error)}")
        schedule_work(30_000)
    end

    {:noreply, state}
  end

  # 4 minutes
  @after_period 4 * 60 * 1000
  defp schedule_work(after_period \\ @after_period) do
    Process.send_after(self(), :loop, after_period)
  end

  defp set_system_time_from_pump(false), do: {:ok}

  defp set_system_time_from_pump(true) do
    with {:ok, pump_time} <- pump().read_time(),
         utc_zoned_time <-
           pump_time
           |> Timex.to_datetime(Configuration.local_timezone())
           |> Timezone.convert(:utc),
         {:ok, formatted_time} <- Timex.format(utc_zoned_time, "%Y-%m-%d %H:%M:%S", :strftime) do
      Logger.warn("Setting system time from pump to #{formatted_time} (UTC)")
      System.cmd("date", ["-s", formatted_time])
      {:ok}
    else
      error -> {:error, error}
    end
  end

  defp pump do
    Application.get_env(:pummpcomm, :pump)
  end
end
