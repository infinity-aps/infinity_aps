defmodule InfinityAPS.Monitor.DetermineBasal do
  require Logger

  def loop do
    Logger.info "Determining Basal!"

    basal_results = determine_basal()
    Logger.info fn() -> "Determine Basal Results: #{basal_results}" end
    write_basal(basal_results)
  end

  defp determine_basal do
    inputs = ["iob.json", "temp_basal.json", "cgm.json", "profile.json"]
    oref0_determine_basal = "#{Application.get_env(:aps, :node_modules_directory)}/oref0/bin/oref0-determine-basal.js"
    {basal_results, 0} = System.cmd("node" , [oref0_determine_basal | inputs], cd: loop_dir())
    basal_results
  end

  defp loop_dir do
    Application.get_env(:aps, :loop_directory) |> Path.expand()
  end

  defp write_basal(basal_results) do
    File.mkdir_p!(loop_dir())
    File.write!("#{loop_dir()}/determine_basal.json", basal_results, [:binary])
  end
end
