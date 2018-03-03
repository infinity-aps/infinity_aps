defmodule InfinityAPS.UI.ConfigurationController do
  @moduledoc false

  use InfinityAPS.UI.Web, :controller

  alias Ecto.Changeset
  alias InfinityAPS.Configuration.ConfigurationData
  alias InfinityAPS.Configuration.Server

  @types %{
    pump_serial: :string,
    wifi_ssid: :string,
    wifi_psk: :string,
    nightscout_url: :string,
    nightscout_token: :string
  }
  def index(conn, _params) do
    data = Server.get_config()
    render_config_data(conn, data)
  end

  def update(conn, params) do
    data = to_struct(ConfigurationData, params["configuration_data"])
    Server.set_config(data)
    Server.save_config()
    render_config_data(conn, data)
  end

  defp render_config_data(conn, config_data) do
    changeset =
      {config_data, @types}
      |> Changeset.cast(%{}, Map.keys(@types))

    render(conn, "index.html", changeset: changeset)
  end

  defp to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
