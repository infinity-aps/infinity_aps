defmodule InfinityAPS.Monitor.CurrentBasalMonitor do
  @moduledoc false
  require Logger

  def loop do
    Logger.debug("Reading temp basal")

    case InfinityAPS.pump().read_temp_basal() do
      {:ok, temp_basal} -> write_oref0(temp_basal)
      response -> Logger.warn("Got: #{inspect(response)}")
    end
  end

  def write_oref0(temp_basal) do
    %{
      duration: temp_basal.duration,
      rate: temp_basal.units_per_hour,
      temp: temp_basal.type
    }
    |> Poison.encode!()
    |> InfinityAPS.write_data("temp_basal.json")
  end
end
