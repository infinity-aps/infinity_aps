defmodule InfinityAPS.UI.PreferencesController do
  @moduledoc false

  use InfinityAPS.UI.Web, :controller

  alias Ecto.Changeset
  alias InfinityAPS.Configuration.Preferences
  alias InfinityAPS.Configuration.Server

  @types %{
    max_iob: :string,
    max_daily_safety_multiplier: :string,
    current_basal_safety_multiplier: :string,
    autosens_max: :string,
    autosens_min: :string,
    rewind_resets_autosens: :boolean,
    adv_target_adjustments: :boolean,
    unsuspend_if_no_temp: :boolean
  }
  def index(conn, _params) do
    preferences = Server.get_config().preferences
    render_preferences(conn, preferences)
  end

  def update(conn, params) do
    preferences = to_struct(Preferences, params["preferences"])
    updated_config = %{Server.get_config() | preferences: preferences}
    Server.set_config(updated_config)
    Server.save_config()
    render_preferences(conn, preferences)
  end

  defp render_preferences(conn, preferences) do
    changeset =
      {preferences, @types}
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
