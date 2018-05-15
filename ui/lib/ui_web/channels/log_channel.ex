defmodule InfinityAPS.UI.LogChannel do
  @moduledoc false

  use Phoenix.Channel

  def join("logs", _message, socket) do
    InfinityAPS.UI.Client.attach
    {:ok, socket}
  end
end
