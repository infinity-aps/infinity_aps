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
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    case read_status_from_disk() do
      {:ok, status} -> {:ok, status}
      _ -> {:ok, %{}}
    end
  end

  def get_predicted_glucose, do: GenServer.call(__MODULE__, {:get_predicted_glucose})
  def update_status_from_disk, do: GenServer.call(__MODULE__, {:update_status_from_disk})

  def handle_call({:get_predicted_glucose}, _sender, state = %{status: status, timestamp: timestamp}) do
    predicted_bgs = timestamp_bgs(status["predBGs"]["IOB"], timestamp)
    {:reply, {:ok, predicted_bgs}, state}
  end

  def handle_call({:update_status_from_disk}, _sender, state) do
    case read_status_from_disk() do
      new_state = %{status: status, timestamp: timestamp} ->
        predicted_bgs = timestamp_bgs(status["predBGs"]["IOB"], timestamp)
        GenServer.cast(:glucose_broker, {:predicted_bgs, predicted_bgs})
        {:reply, :ok, new_state}
      response ->
        {:reply, response, state}

    end
  end

  defp timestamp_bgs(predicted_bgs, timestamp) do
    PredictedBG.apply_timestamp(predicted_bgs, timestamp)
  end

  defp read_status_from_disk do
    case status_file() do
      nil -> {:error, "Status file doesn't exist"}
      file ->
        status = file |> File.read!() |> Poison.decode!()
        info = File.stat!(file)
        timestamp = info.mtime |> Timex.Timezone.convert(:utc)
        Logger.info "Read determine_basal.js from disk. mtime is #{inspect timestamp}"
        {:ok, %{status: status, timestamp: timestamp}}
    end
  end

  defp status_file do
    filename = "#{loop_dir()}/determine_basal.json"
    case File.exists?(filename) do
      true  -> filename
      false -> nil
    end
  end

  defp loop_dir do
    Application.get_env(:aps, :loop_directory) |> Path.expand()
  end
end
