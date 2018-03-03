defmodule InfinityAPS.Monitor.IOBMonitor do
  @moduledoc false
  require Logger

  def loop(timezone) do
    Logger.debug("Calculating IOB")

    case pump().read_time() do
      {:ok, time} ->
        write_time(time, timezone)

        calculate_iob()
        |> write_iob()

      response ->
        Logger.warn("Got: #{inspect(response)}")
    end
  end

  defp pump do
    Application.get_env(:pummpcomm, :pump)
  end

  defp calculate_iob do
    inputs = ["history.json", "profile.json", "clock.json"]

    oref0_calculate_iob =
      "#{Application.get_env(:aps, :node_modules_directory)}/oref0/bin/oref0-calculate-iob.js"

    {iob_results, 0} = System.cmd("node", [oref0_calculate_iob | inputs], cd: loop_dir())
    iob_results
  end

  defp loop_dir do
    Path.expand(Application.get_env(:aps, :loop_directory))
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
    timestamp
    |> Timex.to_datetime(timezone)
    |> Timex.format!("{ISO:Extended}")
  end
end
