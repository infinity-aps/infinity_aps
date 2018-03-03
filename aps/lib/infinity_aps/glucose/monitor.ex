defmodule InfinityAPS.Glucose.Monitor do
  require Logger
  # alias InfinityAPS.Configuration.Server
  alias InfinityAPS.Glucose.Source
  # alias Pummpcomm.Monitor.BloodGlucoseMonitor
  alias InfinityAPS.TwilightInformant

  @minutes_back 1440
  def loop(local_timezone) do
    # source = %BloodGlucoseMonitor{cgm: Application.get_env(:pummpcomm, :cgm)}
    # source = %TwilightInformant{ns_url: Server.get_config(:nightscout_url), api_secret: Server.get_config(:nightscout_token)}
    case Source.get_sensor_values(%TwilightInformant{}, @minutes_back, local_timezone) do
      {:ok, entries} ->
        write_oref0(entries, local_timezone)
        # report_sgvs(entries, local_timezone)
      response       -> Logger.warn "Got: #{inspect(response)}"
    end
  end

  def write_oref0(entries, local_timezone) do
    loop_dir = Application.get_env(:aps, :loop_directory) |> Path.expand()
    File.mkdir_p!(loop_dir)

    encoded = entries
    |> Enum.filter(&filter_sgv/1)
    |> Enum.map(fn(entry) -> map_sgv(entry, local_timezone) end)
    |> Poison.encode!()

    File.write!("#{loop_dir}/cgm.json", encoded, [:binary])
  end

  defp filter_sgv({:sensor_glucose_value, _}), do: true
  defp filter_sgv(_),                          do: false

  defp map_sgv({:sensor_glucose_value, entry_data}, local_timezone) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, local_timezone)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    dateString = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %{type: "sgv", sgv: entry_data.sgv, date: date, dateString: dateString}
  end
end
