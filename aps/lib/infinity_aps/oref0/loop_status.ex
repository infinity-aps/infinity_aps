defmodule InfinityAPS.Oref0.LoopStatus do
  @moduledoc """
    This module serves as a cache of the last loop run status. It contains
    information from `determine_basal` such as predicted BGs and the last basal
    rate adjustment.
  """
  use GenServer
  require Logger

  alias InfinityAPS.Oref0.PredictedBG

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:name] || __MODULE__)
  end

  def init(args) do
    path_state = %{loop_directory: args[:loop_directory]}

    case read_status_from_disk(args[:loop_directory]) do
      {:ok, state} -> {:ok, Map.merge(path_state, state)}
      _ -> {:ok, path_state}
    end
  end

  def get_predicted_glucose(name \\ __MODULE__),
    do: GenServer.call(name, {:get_predicted_glucose})

  def update_status_from_disk(name \\ __MODULE__),
    do: GenServer.call(name, {:update_status_from_disk})

  def handle_call(
        {:get_predicted_glucose},
        _sender,
        state = %{status: status, timestamp: timestamp}
      ) do
    predicted_bgs = timestamp_bgs(status["predBGs"]["IOB"], timestamp)
    {:reply, {:ok, predicted_bgs}, state}
  end

  def handle_call({:get_predicted_glucose}, _sender, state = %{}), do: {:reply, {:ok, []}, state}

  def handle_call({:update_status_from_disk}, _sender, state) do
    case read_status_from_disk(state.loop_directory) do
      {:ok, new_state = %{status: status, timestamp: timestamp}} ->
        predicted_bgs = timestamp_bgs(status["predBGs"]["IOB"], timestamp)
        GenServer.cast(:glucose_broker, {:predicted_bgs, predicted_bgs})
        {:reply, :ok, new_state}

      response ->
        Logger.error("could not update from disk: #{inspect(response)}")
        {:reply, response, state}
    end
  end

  defp timestamp_bgs(predicted_bgs, timestamp) do
    PredictedBG.apply_timestamp(predicted_bgs, timestamp)
  end

  defp read_status_from_disk(loop_directory) do
    with file <- status_file(loop_directory),
         {:ok, contents} <- File.read(file),
         {:ok, status} <- Poison.decode(contents),
         {:ok, info} <- File.stat(file),
         timestamp <- Timex.Timezone.convert(info.mtime, :utc) do
      {:ok, %{status: status, timestamp: timestamp}}
    else
      error -> error
    end
  end

  defp status_file(loop_directory) do
    Path.expand("determine_basal.json", loop_directory)
  end
end
