defmodule InfinityAPS.UI.UserSocket do
  use Phoenix.Socket

  channel("loop_status:*", InfinityAPS.UI.LoopStatusChannel)
  channel("logs", InfinityAPS.UI.LogChannel)

  transport(:websocket, Phoenix.Transports.WebSocket)

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
