defmodule InfinityAPS.Oref0.Entries do
  use GenServer
  require Logger

  alias InfinityAPS.Configuration.Server

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
  def handle_call({:get_sensor_glucose}, _sender, state), do: {:reply, {:error, "No sgvs cached"}, state}

  def handle_call({:write_entries, entries}, _sender, state) do
    loop_dir = Application.get_env(:aps, :loop_directory) |> Path.expand()
    File.mkdir_p!(loop_dir)

    filtered_entries = entries
    |> Enum.filter(&filter_sgv/1)
    |> Enum.map(fn(entry) -> map_sgv(entry, local_timezone) end)

    File.write!("#{loop_dir}/cgm.json", Poison.encode!(filtered_entries), [:binary])

    chronological_entries = Enum.reverse(filtered_entries)
    GenServer.cast(:glucose_broker, {:sgvs, chronological_entries})
    {:reply, {:ok, %{sgvs: chronological_entries}}, %{sgvs: chronological_entries}}
  end

  defp filter_sgv({:sensor_glucose_value, _}), do: true
  defp filter_sgv(_),                          do: false

  defp map_sgv({:sensor_glucose_value, entry_data}, local_timezone) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, local_timezone)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    dateString = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %{type: "sgv", sgv: entry_data.sgv, date: date, dateString: dateString}
  end

  defp local_timezone do
    Server.get_config(:timezone) |> Timex.Timezone.get()
  end
end
