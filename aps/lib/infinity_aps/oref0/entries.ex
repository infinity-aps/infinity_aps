defmodule InfinityAPS.Oref0.Entries do
  @moduledoc false
  use GenServer
  require Logger

  alias InfinityAPS.Configuration

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def get_sensor_glucose, do: GenServer.call(__MODULE__, {:get_sensor_glucose})
  def write_entries(entries), do: GenServer.call(__MODULE__, {:write_entries, entries})

  def handle_call({:get_sensor_glucose}, _sender, state = %{sgvs: sgvs}) do
    {:reply, {:ok, sgvs}, state}
  end

  def handle_call({:get_sensor_glucose}, _sender, state),
    do: {:reply, {:error, "No sgvs cached"}, state}

  def handle_call({:write_entries, entries}, _sender, _state) do
    filtered_entries =
      entries
      |> Enum.filter(&InfinityAPS.filter_sgv/1)
      |> Enum.map(fn entry -> InfinityAPS.map_sgv(entry, Configuration.local_timezone()) end)

    filtered_entries
    |> Poison.encode!()
    |> InfinityAPS.write_data("cgm.json")

    chronological_entries = Enum.reverse(filtered_entries)
    GenServer.cast(:glucose_broker, {:sgvs, chronological_entries})
    {:reply, {:ok, %{sgvs: chronological_entries}}, %{sgvs: chronological_entries}}
  end
end
