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
