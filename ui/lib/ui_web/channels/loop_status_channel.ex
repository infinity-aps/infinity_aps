defmodule InfinityAPS.UI.LoopStatusChannel do
  use Phoenix.Channel

  require Logger

  alias InfinityAPS.Configuration.Server
  alias InfinityAPS.Glucose.Source
  alias InfinityAPS.TwilightInformant
  alias Pummpcomm.Monitor.BloodGlucoseMonitor

  @minutes_back 1440
  def join("loop_status:glucose", _message, socket) do
    source = %BloodGlucoseMonitor{cgm: Application.get_env(:pummpcomm, :cgm)}
    case Source.get_sensor_values(source, @minutes_back, local_timezone) do
      {:ok, entries} ->
        message = map_entries(entries, local_timezone())
        send(self, {:after_join, message})
      response       ->
        Logger.warn "Got: #{inspect(response)}"
    end

    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    push socket, "sgvs", %{data: message}
    {:noreply, socket}
  end

  defp map_entries(entries, local_timezone) do
    encoded = entries
    |> Enum.filter(&filter_sgv/1)
    |> Enum.map(fn(entry) -> map_sgv(entry, local_timezone) end)
  end

  defp filter_sgv({:sensor_glucose_value, _}), do: true
  defp filter_sgv(_),                          do: false

  defp map_sgv({:sensor_glucose_value, entry_data}, local_timezone) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, local_timezone)
    dateString = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %{type: "sgv", sgv: entry_data.sgv, dateString: dateString}
  end

  defp local_timezone do
    Server.get_config(:timezone) |> Timex.Timezone.get()
  end
end
