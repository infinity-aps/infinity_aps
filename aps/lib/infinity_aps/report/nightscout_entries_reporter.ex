defmodule InfinityAPS.Report.NightscoutEntriesReporter do
  require Logger

  def report_sgvs(entries, local_timezone) do
    Logger.debug("Posting entries")

    response =
      entries
      |> Enum.filter(&filter_sgv/1)
      |> Enum.map(fn entry -> map_sgv(entry, local_timezone) end)
      |> TwilightInformant.post_entries()

    case response do
      {:ok, _} ->
        Logger.info("Finished posting successfully")

      error ->
        Logger.error(fn -> "Could not post entries: #{inspect(error)}" end)
    end

    response
  end

  defp filter_sgv({:sensor_glucose_value, _}), do: true
  defp filter_sgv(_), do: false

  defp map_sgv({:sensor_glucose_value, entry_data}, local_timezone) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, local_timezone)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    dateString = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %{type: "sgv", sgv: entry_data.sgv, date: date, dateString: dateString}
  end
end
