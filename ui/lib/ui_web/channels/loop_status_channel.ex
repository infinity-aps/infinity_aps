defmodule InfinityAPS.UI.LoopStatusChannel do
  use Phoenix.Channel

  require Logger

  alias InfinityAPS.UI.GlucoseBroker

  def join("loop_status:glucose", _message, socket) do
    send(self(), {:after_join_glucose})
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
end
