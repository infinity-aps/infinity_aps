defmodule InfinityAPS.UI.LogChannel do
  @moduledoc false

  use Phoenix.Channel

  alias InfinityAPS.UI.Client

  def join("logs", _message, socket) do
    Client.attach()
    {:ok, socket}
  end
end
