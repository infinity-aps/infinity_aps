defmodule InfinityAPS.Monitor.IOBMonitor do
  @moduledoc false
  require Logger

  def loop(timezone) do
    Logger.debug("Calculating IOB")

    case InfinityAPS.pump().read_time() do
      {:ok, time} ->
        time
        |> InfinityAPS.formatted_time(timezone)
        |> Poison.encode!()
        |> InfinityAPS.write_data("clock.json")

        calculate_iob()
        |> InfinityAPS.write_data("iob.json")

      response ->
        Logger.warn("Got: #{inspect(response)}")
    end
  end

  defp calculate_iob do
    inputs = ["history.json", "profile.json", "clock.json"]

    oref0_calculate_iob = InfinityAPS.node_modules_directory("oref0/bin/oref0-calculate-iob.js")

    {iob_results, 0} =
      System.cmd(
        "node",
        [oref0_calculate_iob | inputs],
        cd: InfinityAPS.loop_directory()
      )

    iob_results
  end
end
