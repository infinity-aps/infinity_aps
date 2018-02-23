defmodule InfinityAPS.UI.GlucoseBroker do
  use GenServer
  require Logger

  alias InfinityAPS.Oref0.LoopStatus
  alias InfinityAPS.Oref0.Entries

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :glucose_broker)
  end

  def get_sensor_glucose do
    Entries.get_sensor_glucose()
  end

  def get_predicted_bgs do
    LoopStatus.get_predicted_glucose()
  end

  def handle_cast({:sgvs, sgvs}, state) do
    Logger.warn InfinityAPS.UI.Endpoint.broadcast("loop_status:glucose", "sgvs", %{data: sgvs})
    {:noreply, state}
  end

  def handle_cast({:predicted_bgs, predicted_bgs}, state) do
    Logger.warn InfinityAPS.UI.Endpoint.broadcast("loop_status:glucose", "predicted_bgs", %{data: predicted_bgs})
    {:noreply, state}
  end
end
