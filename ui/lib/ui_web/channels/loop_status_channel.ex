defmodule InfinityAPS.UI.LoopStatusChannel do
  use Phoenix.Channel

  require Logger

  alias InfinityAPS.Configuration.Server
  alias InfinityAPS.Glucose.Source
  alias InfinityAPS.UI.GlucoseBroker
  alias Pummpcomm.Monitor.BloodGlucoseMonitor
  alias Pummpcomm.Monitor.HistoryMonitor

  @minutes_back 720
  def join("loop_status:glucose", _message, socket) do
    send(self(), {:after_join_glucose})
    {:ok, socket}
  end

  def join("loop_status:basal", _message, socket) do
    send(self(), {:after_join_basal})
    {:ok, socket}
  end

  def handle_info({:after_join_glucose}, socket) do
    case GlucoseBroker.get_sensor_glucose() do
      {:ok, svgs} -> push socket, "sgvs", %{data: svgs}
      response             -> Logger.warn "Got: #{inspect(response)}"
    end

    case GlucoseBroker.get_predicted_bgs() do
      {:ok, predicted_bgs} -> push socket, "predicted_bgs", %{data: predicted_bgs}
      response             -> Logger.warn "Got: #{inspect(response)}"
    end

    {:noreply, socket}
  end

  def handle_info({:after_join_basal}, socket) do
    case HistoryMonitor.get_pump_history(@minutes_back, local_timezone()) do
      {:ok, history} ->
        # message = map_history(history, local_timezone())
        message = history
        push socket, "basal", %{data: message}
      response       ->
        Logger.warn "Got: #{inspect(response)}"
    end
    {:noreply, socket}
  end

  defp map_entries(entries, local_timezone) do
    entries
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
