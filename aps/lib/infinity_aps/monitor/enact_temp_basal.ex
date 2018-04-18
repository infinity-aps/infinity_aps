defmodule InfinityAPS.Monitor.EnactTempBasal do
  @moduledoc false
  require Logger

  def loop do
    result = read_determine_basal()

    case Map.has_key?(result, "rate") do
      true -> enact_basal(result)
      false -> Logger.info("No basal adjustment needed")
    end
  end

  defp read_determine_basal do
    InfinityAPS.loop_directory()
    |> Path.join("determine_basal.json")
    |> File.read!()
    |> Poison.decode!()
  end

  defp enact_basal(basal_results) do
    Logger.info(fn ->
      ~s(Setting temp basal to #{basal_results["rate"]} for #{basal_results["duration"]} minutes)
    end)

    InfinityAPS.pump().set_temp_basal(
      units_per_hour: basal_results["rate"],
      duration_minutes: basal_results["duration"],
      type: :absolute
    )
  end
end
