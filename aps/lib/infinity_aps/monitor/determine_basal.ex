defmodule InfinityAPS.Monitor.DetermineBasal do
  @moduledoc false
  require Logger

  def loop do
    Logger.info("Determining Basal!")

    basal_results = determine_basal()
    Logger.info(fn -> "Determine Basal Results: #{basal_results}" end)
    InfinityAPS.write_data(basal_results, "determine_basal.json")
  end

  defp determine_basal do
    inputs = ["iob.json", "temp_basal.json", "cgm.json", "profile.json"]

    oref0_determine_basal =
      InfinityAPS.node_modules_directory("oref0/bin/oref0-determine-basal.js")

    {basal_results, 0} =
      System.cmd(
        "node",
        [oref0_determine_basal | inputs],
        cd: InfinityAPS.loop_directory()
      )

    basal_results
  end
end
