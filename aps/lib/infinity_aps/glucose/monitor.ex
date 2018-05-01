defmodule InfinityAPS.Glucose.Monitor do
  @moduledoc false
  require Logger
  alias InfinityAPS.Glucose.Source
  alias InfinityAPS.TwilightInformant

  @minutes_back 1440
  def loop(local_timezone) do
    case Source.get_sensor_values(%TwilightInformant{}, @minutes_back, local_timezone) do
      {:ok, entries} ->
        write_oref0(entries, local_timezone)

      response ->
        Logger.warn("Got: #{inspect(response)}")
    end
  end

  def write_oref0(entries, local_timezone) do
    entries
    |> Enum.filter(&filter_sgv/1)
    |> Enum.map(fn entry -> map_sgv(entry, local_timezone) end)
    |> Poison.encode!()
    |> InfinityAPS.write_data("cgm.json")
  end

  @doc """
  Returns true if the input is a sensor_glucose_value.
  Otherwise, it returns false.

  Used for sgv filtering with Enum.filter/1.
  """
  def filter_sgv({:sensor_glucose_value, _}), do: true
  def filter_sgv(_), do: false

  @doc """
  Converts the sensor_glucose_value `entry_data` into an sgv entry, taking into account
  the `local_timezone`.
  """
  def map_sgv({:sensor_glucose_value, entry_data}, local_timezone) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, local_timezone)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    date_string = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %{type: "sgv", sgv: entry_data.sgv, date: date, dateString: date_string}
  end
end
