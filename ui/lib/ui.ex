defmodule InfinityAPS.UI do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(InfinityAPS.UI.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: InfinityAPS.UI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    InfinityAPS.UI.Endpoint.config_change(changed, removed)
    :ok
  end
end
