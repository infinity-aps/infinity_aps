defmodule InfinityAPS.Monitor.GlucoseMonitor do
  require Logger
  alias InfinityAPS.Glucose.Source
  alias Pummpcomm.Monitor.BloodGlucoseMonitor
  alias InfinityAPS.Oref0.Entries

  @minutes_back 720
  def loop(local_timezone) do
    source = %BloodGlucoseMonitor{cgm: Application.get_env(:pummpcomm, :cgm)}
    case Source.get_sensor_values(source, @minutes_back, local_timezone) do
      {:ok, entries} ->
        Entries.write_entries(entries)
      response       -> Logger.warn "Got: #{inspect(response)}"
    end
  end

  # def report_sgvs(entries, local_timezone) do
  #   Logger.debug "Posting entries"
  #   response = entries
  #   |> Enum.filter(&filter_sgv/1)
  #   |> Enum.map(fn(entry) -> map_sgv(entry, local_timezone) end)
  #   |> TwilightInformant.post_entries()

  #   case response do
  #     {:ok, _} ->
  #       Logger.info "Finished posting successfully"
  #     error ->
  #       Logger.error fn() -> "Could not post entries: #{inspect error}" end
  #   end
  #   response
  # end
end
