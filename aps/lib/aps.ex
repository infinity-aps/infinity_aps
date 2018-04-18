defmodule InfinityAPS do
  @moduledoc """
  Functions used throughout `aps`.
  """

  @doc """
  Returns the environment variable of the loop directory,
  where oref0 can find and save the json files needed to loop.
  """
  def loop_directory do
    Application.get_env(:aps, :loop_directory)
  end

  @doc """
  Returns the environment variable of the configuration file.
  """
  def configuration_file do
    Application.get_env(:aps, :configuration_file)
  end

  @doc """
  Returns the environment variable of the node_modules directory.

  It joins any `file_path` given.
  """
  def node_modules_directory(file_path \\ "") do
    Path.join(Application.get_env(:aps, :node_modules_directory), file_path)
  end

  @doc """
  Returns the environment variable of the module responsible
  for pump communication.
  """
  def pump do
    Application.get_env(:pummpcomm, :pump)
  end

  @doc """
  Returns the environment variable of the module responsible
  for cgm communication.
  """
  def cgm do
    Application.get_env(:pummpcomm, :cgm)
  end

  @doc """
  Returns true if the input is a sensor_glucose_value.
  Otherwise, it returns false.

  Used for sgv filtering with Enum.filter\1.
  """
  def filter_sgv({:sensor_glucose_value, _}), do: true
  def filter_sgv(_), do: false

  @doc """
  Converts the sensor_glucose_value `entry_data` into an sgv entry, taking into account
  the `local_timezone`.
  """
  def map_sgv({:sensor_glucose_value, entry_data}, local_timezone) do
    date_with_zone = Timex.to_datetime(entry_data.timestamp, local_timezone)
    date = DateTime.to_unix(date_with_zone, :milliseconds)
    date_string = Timex.format!(date_with_zone, "{ISO:Extended:Z}")
    %{type: "sgv", sgv: entry_data.sgv, date: date, dateString: date_string}
  end

  @doc """
  Writes `encoded` data in `file_name` in the path given by `InfinityAPS.loop_directory()`.
  """
  def write_data(encoded, file_name) do
    loop_dir = InfinityAPS.loop_directory()
    File.mkdir_p!(loop_dir)

    loop_dir
    |> Path.join(file_name)
    |> File.write!(encoded, [:binary])
  end

  @doc """
  Formats `timestamp` to ISO:Extended format, taking into account the `local_timezone`.
  """
  def formatted_time(timestamp, local_timezone) do
    timestamp
    |> Timex.to_datetime(local_timezone)
    |> Timex.format!("{ISO:Extended}")
  end
end
