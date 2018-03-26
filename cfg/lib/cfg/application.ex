defmodule InfinityAPS.Configuration.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(InfinityAPS.Configuration, [
        Keyword.get(Application.get_env(:cfg, InfinityAPS.Configuration), :file)
      ])
    ]

    opts = [strategy: :one_for_one, name: InfinityAPS.Configuration.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
