defmodule InfinityAPS.Monitor.IOBMonitor do
  require Logger

  def loop(timezone) do
    Logger.debug "Calculating IOB"

    case Pummpcomm.Session.Pump.read_time() do
      {:ok, time} ->
        write_time(time, timezone)
        calculate_iob()
        |> write_iob()
      response          -> Logger.warn "Got: #{inspect(response)}"
    end
  end

  defp calculate_iob do
    inputs = ["history.json", "profile.json", "clock.json"]
    {iob_results, 0} = System.cmd("node", ["/usr/lib/node_modules/oref0/bin/oref0-calculate-iob.js" | inputs], cd: loop_dir())
    iob_results
  end

  defp loop_dir do
    Application.get_env(:infinity_aps, :loop_directory) |> Path.expand()
  end

  defp write_iob(iob_results) do
    File.mkdir_p!(loop_dir())
    File.write!("#{loop_dir()}/iob.json", iob_results, [:binary])
  end

  defp write_time(time, timezone) do
    File.mkdir_p!(loop_dir())
    File.write!("#{loop_dir()}/clock.json", ~s("#{formatted_time(time, timezone)}"), [:binary])
  end

  defp formatted_time(timestamp, timezone) do
    Timex.to_datetime(timestamp, timezone)
    |> Timex.format!("{ISO:Extended}")
  end
end
