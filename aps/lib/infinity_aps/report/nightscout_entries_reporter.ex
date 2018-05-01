defmodule InfinityAPS.Report.NightscoutEntriesReporter do
  @moduledoc false
  require Logger

  alias InfinityAPS.Glucose.Monitor

  def report_sgvs(entries, local_timezone) do
    Logger.debug("Posting entries")

    response =
      entries
      |> Enum.filter(&Monitor.filter_sgv/1)
      |> Enum.map(fn entry -> Monitor.map_sgv(entry, local_timezone) end)
      |> TwilightInformant.post_entries()

    case response do
      {:ok, _} ->
        Logger.info("Finished posting successfully")

      error ->
        Logger.error(fn -> "Could not post entries: #{inspect(error)}" end)
    end

    response
  end
end
