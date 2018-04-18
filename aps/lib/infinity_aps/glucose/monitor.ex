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
    |> Enum.filter(&InfinityAPS.filter_sgv/1)
    |> Enum.map(fn entry -> InfinityAPS.map_sgv(entry, local_timezone) end)
    |> Poison.encode!()
    |> InfinityAPS.write_data("cgm.json")
  end
end
