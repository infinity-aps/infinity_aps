defmodule NervesAps.Configuration.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(NervesAps.Configuration.Server,
        [Keyword.get(Application.get_env(:cfg, NervesAps.Configuration), :file)])
    ]

    opts = [strategy: :one_for_one, name: NervesAps.Configuration.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
