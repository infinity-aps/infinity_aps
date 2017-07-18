defmodule NervesAps.Monitor.Loop do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:loop, state) do
    Logger.warn "Getting sensor values"
    response = Pummpcomm.Monitor.BloodGlucoseMonitor.get_sensor_values(20)
    Logger.warn "Got: #{inspect(response)}"
    with {:ok, entries} <- response do
      report_sgvs(entries)
    end
    schedule_work()
    {:noreply, state}
  end

  @nightscout_url "#{Application.get_env(:nightscout, :url)}/api/v1/entries.json?token=#{Application.get_env(:nightscout, :token)}"
  def report_sgvs(entries) do
    entries
    |> Enum.filter_map(&filter_sgv/1, &map_sgv/1)
    |> filter_duplicates()
    |> TwilightInformant.Entry.post(@nightscout_url)
  end

  defp filter_duplicates(entries) do
    # TwilightInformant.Entry.gaps()
    entries
  end

  defp filter_sgv({:sensor_glucose_value, _}), do: true
  defp filter_sgv(_),                          do: false

  defp map_sgv({:sensor_glucose_value, entry_data}) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, :local)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    dateString = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %TwilightInformant.Entry{type: "sgv", sgv: entry_data.sgv, date: date, dateString: dateString}
  end

  @after_period 5 * 60 * 1000 # 5 minutes
  defp schedule_work(after_period \\ @after_period) do
    Process.send_after(self(), :loop, after_period)
  end
end
