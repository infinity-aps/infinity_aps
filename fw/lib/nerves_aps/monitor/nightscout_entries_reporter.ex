defmodule InfinityAPS.Monitor.NightscoutEntriesReporter do
  require Logger
  alias InfinityAPS.Configuration.Server

  @minutes_back 1440
  def loop do
    Logger.debug "Getting sensor values for #{@minutes_back} minutes back"
    case Pummpcomm.Monitor.BloodGlucoseMonitor.get_sensor_values(@minutes_back) do
      {:ok, entries} ->
        write_oref0(entries)
        report_sgvs(entries)
      response       -> Logger.warn "Got: #{inspect(response)}"
    end
  end

  def write_oref0(entries) do
    File.mkdir_p!("/root/loop")

    encoded = entries
    |> Enum.filter(&filter_sgv/1)
    |> Enum.map(&map_sgv/1)
    |> Poison.encode!()

    File.write!("/root/loop/cgm.json", encoded, [:binary])
  end

  def report_sgvs(entries) do
    Logger.debug "Posting entries"
    response = entries
    |> Enum.filter_map(&filter_sgv/1, &map_sgv/1)
    |> TwilightInformant.Entry.post(entries_url())
    Logger.debug "Finished posting #{inspect response}"
    response
  end

  defp entries_url do
    "#{Server.get_config(:nightscout_url)}/api/v1/entries.json?token=#{Server.get_config(:nightscout_token)}"
  end

  defp filter_sgv({:sensor_glucose_value, _}), do: true
  defp filter_sgv(_),                          do: false

  defp map_sgv({:sensor_glucose_value, entry_data}) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, :local)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    dateString = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %TwilightInformant.Entry{type: "sgv", sgv: entry_data.sgv, date: date, dateString: dateString}
  end
end
