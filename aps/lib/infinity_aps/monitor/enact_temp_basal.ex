defmodule InfinityAPS.Monitor.EnactTempBasal do
  require Logger

  def loop do
    result = determine_basal()

    case Map.has_key?(result, "rate") do
      true -> enact_basal(result)
      false -> Logger.info("No basal adjustment needed")
    end
  end

  defp determine_basal do
    File.read!("#{loop_dir()}/determine_basal.json") |> Poison.decode!()
  end

  defp loop_dir do
    Application.get_env(:aps, :loop_directory) |> Path.expand()
  end

  defp enact_basal(basal_results) do
    Logger.info(fn ->
      ~s(Setting temp basal to #{basal_results["rate"]} for #{basal_results["duration"]} minutes)
    end)

    pump().set_temp_basal(
      units_per_hour: basal_results["rate"],
      duration_minutes: basal_results["duration"],
      type: :absolute
    )
  end

  defp pump do
    Application.get_env(:pummpcomm, :pump)
  end
end
