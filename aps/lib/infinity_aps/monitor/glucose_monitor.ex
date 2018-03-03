defmodule InfinityAPS.Monitor.GlucoseMonitor do
  @moduledoc false
  require Logger

  alias InfinityAPS.Glucose.Source
  alias InfinityAPS.Report.NightscoutEntriesReporter
  alias Pummpcomm.Monitor.BloodGlucoseMonitor
  alias InfinityAPS.Oref0.Entries

  @minutes_back 360
  def loop(local_timezone) do
    source = %BloodGlucoseMonitor{cgm: Application.get_env(:pummpcomm, :cgm)}

    case Source.get_sensor_values(source, @minutes_back, local_timezone) do
      {:ok, entries} ->
        Entries.write_entries(entries)
        NightscoutEntriesReporter.report_sgvs(entries, local_timezone)

      response ->
        Logger.warn("Got: #{inspect(response)}")
    end
  end
end
