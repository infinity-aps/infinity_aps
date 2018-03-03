defprotocol InfinityAPS.Glucose.Source do
  def get_sensor_values(source, minutes_back, timezone)
end

defimpl InfinityAPS.Glucose.Source, for: Pummpcomm.Monitor.BloodGlucoseMonitor do
  defdelegate get_sensor_values(source, minutes_back, timezone),
    to: Pummpcomm.Monitor.BloodGlucoseMonitor
end

defmodule InfinityAPS.TwilightInformant do
  @moduledoc false
  defstruct [:ns_url, :api_secret, :httpoison_opts]
end

defimpl InfinityAPS.Glucose.Source, for: InfinityAPS.TwilightInformant do
  require Logger

  def get_sensor_values(_source, minutes_back, timezone) do
    time_back = minimum_date(minutes_back, timezone)
    result = TwilightInformant.entries(count: 600, "find[dateString][$gte]": time_back)
    Logger.error("Result: #{inspect(result)}")
    result
  end

  def minimum_date(minutes_back, timezone) do
    # :utc |> Timex.now() |>  Timex.shift(minutes: -minutes_back) |> Timex.format!("{ISO:Extended:Z}")
    timezone |> Timex.now() |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive()
  end
end
