defmodule InfinityAPS.UI do
  @moduledoc false

  use Application

  alias InfinityAPS.UI.GlucoseBroker
  alias InfinityAPS.UI.Endpoint
  alias InfinityAPS.UI.Client

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Endpoint, []),
      GlucoseBroker.child_spec(nil),
      Client
    ]

    opts = [strategy: :one_for_one, name: InfinityAPS.UI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
