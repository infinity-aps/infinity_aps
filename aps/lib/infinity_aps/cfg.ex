defmodule InfinityAPS.Configuration do
  @moduledoc false
  alias InfinityAPS.Configuration.Server
  alias InfinityAPS.Configuration.ConfigurationData
  alias Timex.Timezone

  def get_config do
    GenServer.call(Server, {:get_config})
  end

  def get_config(key) do
    GenServer.call(Server, {:get_config, key})
  end

  def set_config(config = %ConfigurationData{}) do
    GenServer.call(Server, {:set_config, config})
  end

  def set_config(key, value) do
    GenServer.call(Server, {:set_config, key, value})
  end

  def save_config do
    GenServer.call(Server, {:save_config})
  end

  def local_timezone do
    :timezone |> get_config() |> Timezone.get()
  end
end
