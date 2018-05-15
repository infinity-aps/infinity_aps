defmodule InfinityAPS.UI.Client do
  use GenServer

  alias InfinityAPS.UI.Endpoint
  alias Logger.Formatter

  @moduledoc """
  Interact with the RingLogger
  """

  alias RingLogger.Server

  defmodule State do
    @moduledoc false
    defstruct io: nil,
              colors: nil,
              metadata: nil,
              format: nil,
              level: nil,
              index: 0
  end

  @doc """
  Start up a client GenServer. Except for just getting the contents of the ring buffer, you'll
  need to create one of these. See `configure/2` for information on options.
  """
  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc """
  Stop a client.
  """
  def stop do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Update the client configuration.

  Options include:
  * `:io` - Defaults to `:stdio`
  * `:colors` -
  * `:metadata` - A KV list of additional metadata
  * `:format` - A custom format string, or a {module, function} tuple (see
    https://hexdocs.pm/logger/master/Logger.html#module-custom-formatting)
  * `:level` - The minimum log level to report.
  """
  @spec configure([RingLogger.client_option()]) :: :ok
  def configure(config) do
    GenServer.call(__MODULE__, {:config, config})
  end

  @doc """
  Attach the current IEx session to the logger. It will start printing log messages.
  """
  @spec attach() :: :ok
  def attach do
    GenServer.call(__MODULE__, :attach)
  end

  @doc """
  Detach the current IEx session from the logger.
  """
  @spec detach() :: :ok
  def detach do
    GenServer.call(__MODULE__, :detach)
  end

  @doc """
  Tail the messages in the log.
  """
  @spec tail() :: :ok
  def tail do
    GenServer.call(__MODULE__, :tail)
  end

  @doc """
  Reset the index into the log for `tail/1` to the oldest entry.
  """
  @spec reset() :: :ok
  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Helper method for formatting log messages per the current client's
  configuration.
  """
  @spec format(RingLogger.entry()) :: :ok
  def format(message) do
    GenServer.call(__MODULE__, {:format, message})
  end

  @doc """
  Run a regular expression on each entry in the log and print out the matchers.
  """
  @spec grep(Regex.t()) :: :ok
  def grep(regex) do
    GenServer.call(__MODULE__, {:grep, regex})
  end

  def init(config) do
    state = %State{
      io: Keyword.get(config, :io, :stdio),
      colors: configure_colors(config),
      metadata: config |> Keyword.get(:metadata, []) |> configure_metadata(),
      format: config |> Keyword.get(:format) |> configure_formatter(),
      level: Keyword.get(config, :level, :debug)
    }

    {:ok, state}
  end

  def handle_info({:log, msg}, state) do
    maybe_send(msg, state)
    {:noreply, state}
  end

  def handle_call({:config, config}, _from, state) do
    new_io = Keyword.get(config, :io, state.io)
    new_level = Keyword.get(config, :level, state.level)

    new_state = %State{state | io: new_io, level: new_level}

    {:reply, :ok, new_state}
  end

  def handle_call(:attach, _from, state) do
    {:reply, Server.attach_client(self()), state}
  end

  def handle_call(:detach, _from, state) do
    {:reply, Server.detach_client(self()), state}
  end

  def handle_call(:tail, _from, state) do
    messages = Server.get(state.index)

    case List.last(messages) do
      nil ->
        # No messages
        {:reply, :ok, state}

      last_message ->
        Enum.each(messages, fn msg -> maybe_send(msg, state) end)
        next_index = message_index(last_message) + 1
        {:reply, :ok, %{state | index: next_index}}
    end
  end

  def handle_call(:reset, _from, state) do
    {:reply, :ok, %{state | index: 0}}
  end

  def handle_call({:grep, regex}, _from, state) do
    Server.get()
    |> Enum.each(fn msg -> maybe_send(msg, regex, state) end)

    {:reply, :ok, state}
  end

  def handle_call({:format, msg}, _from, state) do
    item = format_message(msg, state)
    {:reply, item, state}
  end

  defp message_index({_level, {_, _msg, _ts, md}}), do: Keyword.get(md, :index)

  defp format_message({level, {_, msg, ts, md}}, state) do
    metadata = take_metadata(md, state.metadata)

    """
    Note: A log can be converted to a map with a single string (as done here)
          or they can be a map with multiple fields (commented out).

    {d, t} = ts
    date = Logger.Formatter.format_date(d)
           |> IO.chardata_to_string
    time = Logger.Formatter.format_time(t)
           |> IO.chardata_to_string
    state.format
    |> apply_format(level, msg, ts, metadata)
    %{level: level |> Atom.to_string, msg: msg |> IO.chardata_to_string, date: date, time: time, metadata: metadata}
    """

    state.format
    |> apply_format(level, msg, ts, metadata)
    |> IO.chardata_to_string()
    |> String.trim()
  end

  ## Helpers

  defp apply_format({mod, fun}, level, msg, ts, metadata) do
    apply(mod, fun, [level, msg, ts, metadata])
  end

  defp apply_format(format, level, msg, ts, metadata) do
    Formatter.format(format, level, msg, ts, metadata)
  end

  defp configure_metadata(:all), do: :all
  defp configure_metadata(metadata), do: Enum.reverse(metadata)

  defp configure_colors(config) do
    colors = Keyword.get(config, :colors, [])

    %{
      debug: Keyword.get(colors, :debug, :cyan),
      info: Keyword.get(colors, :info, :normal),
      warn: Keyword.get(colors, :warn, :yellow),
      error: Keyword.get(colors, :error, :red),
      enabled: Keyword.get(colors, :enabled, IO.ANSI.enabled?())
    }
  end

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
  end

  defp color_event(data, _level, %{enabled: false}, _md), do: data

  defp color_event(data, level, %{enabled: true} = colors, md) do
    color = md[:ansi_color] || Map.fetch!(colors, level)
    [IO.ANSI.format_fragment(color, true), data | IO.ANSI.reset()]
  end

  defp configure_formatter({mod, fun}), do: {mod, fun}

  defp configure_formatter(format) do
    Formatter.compile(format)
  end

  defp maybe_print({level, _} = msg, state) do
    if meet_level?(level, state.level) do
      item = format_message(msg, state)
      IO.binwrite(state.io, item)
    end
  end

  defp maybe_print({level, {_, text, _, _}} = msg, r, state) do
    flattened_text = IO.iodata_to_binary(text)

    if meet_level?(level, state.level) && Regex.match?(r, flattened_text) do
      item = format_message(msg, state)
      IO.binwrite(state.io, item)
    end
  end

  defp maybe_send({level, _} = msg, state) do
    if meet_level?(level, state.level) do
      item = format_message(msg, state)
      Endpoint.broadcast!("logs", "log:new", %{msg: item})
    end
  end

  defp maybe_send({level, {_, text, _, _}} = msg, r, state) do
    flattened_text = IO.iodata_to_binary(text)

    if meet_level?(level, state.level) && Regex.match?(r, flattened_text) do
      item = format_message(msg, state)
      Endpoint.broadcast!("logs", "log:new", %{msg: item})
    end
  end
end
