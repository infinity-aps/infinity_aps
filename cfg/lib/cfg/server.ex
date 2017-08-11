defmodule NervesAps.Configuration.Server do
  use GenServer

  def start_link(file) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, Path.expand(file), name: __MODULE__)
  end

  def init(file) do
    :ok = File.mkdir_p(Path.dirname(file))
    :ok = File.touch(file)
    read_config(file)
  end

  def get_config(key) do
    GenServer.call __MODULE__, {:get_config, key}
  end

  def set_config(key, value) do
    GenServer.call __MODULE__, {:set_config, key, value}
  end

  def save_config() do
    GenServer.call __MODULE__, {:save_config}
  end

  def handle_call({:get_config, key}, _from, state = {_file, config_map}) do
    {:reply, Map.get(config_map, key), state}
  end

  def handle_call({:set_config, key, value}, _from, {file, config_map}) do
    {:reply, :ok, {file, Map.put(config_map, key, value)}}
  end

  def handle_call({:save_config}, _from, state) do
    {:reply, write_config(state), state}
  end

  defp read_config(file) do
    with {:ok, config_data} <- File.read(file),
         {:ok, config_map} <- decode_config(config_data) do
      {:ok, {file, atomize_keys(config_map)}}
    else
      error -> {:error, "Unable to read configuration data: #{error}"}
    end
  end

  defp decode_config(<<>>), do: {:ok, %{}}
  defp decode_config(config_data) when is_binary(config_data), do: Poison.decode(config_data)

  defp atomize_keys(config_map) do
    config_map
    |> Enum.reduce(%{}, fn({key, value}, acc) -> Map.put(acc, String.to_atom(key), value) end)
  end

  defp write_config({file, config_map}) do
    with {:ok, config_data} <- Poison.encode(config_map),
         :ok <- File.write(file, config_data) do
      :ok
    else
      error -> {:error, "Unable to write configuration data: #{error}"}
    end
  end
end
