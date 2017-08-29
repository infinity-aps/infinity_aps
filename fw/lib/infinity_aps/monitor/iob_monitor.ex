defmodule InfinityAPS.Monitor.IOBMonitor do
  require Logger

  def loop do
    Logger.debug "Calculating IOB"

    case Pummpcomm.Session.Pump.read_time() do
      {:ok, time} ->
        write_time(time)
        calculate_iob()
        |> write_iob()
      response          -> Logger.warn "Got: #{inspect(response)}"
    end
  end

  defp calculate_iob do
    inputs = ["history.json", "profile.json", "clock.json"]
    {iob_results, 0} = System.cmd("oref0-calculate-iob", inputs, cd: loop_dir())
    iob_results
  end

  defp loop_dir do
    Application.get_env(:infinity_aps, :loop_directory) |> Path.expand()
  end

  defp write_iob(iob_results) do
    File.mkdir_p!(loop_dir())
    File.write!("#{loop_dir()}/iob.json", iob_results, [:binary])
  end

  defp write_time(time) do
    File.mkdir_p!(loop_dir())
    File.write!("#{loop_dir()}/clock.json", ~s("#{formatted_time(time)}"), [:binary])
  end

  defp formatted_time(timestamp) do
    Timex.to_datetime(timestamp, :local)
    |> Timex.format!("{ISO:Extended}")
  end
end
