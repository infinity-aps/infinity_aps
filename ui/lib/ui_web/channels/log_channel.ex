defmodule InfinityAPS.UI.LogChannel do
  @moduledoc false

  use Phoenix.Channel

  alias InfinityAPS.UI.Client

  def join("logs", _message, socket) do
    send(self(), {:after_join_attach})
    {:ok, socket}
  end

  def handle_info({:after_join_attach}, socket) do
    Client.tail()
    Client.attach()
    {:noreply, socket}
  end
end
