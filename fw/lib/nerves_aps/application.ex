defmodule NervesAps.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Pummpcomm.Driver.SubgRfspy.UART, []),
      worker(Pummpcomm.Session.Pump, []),
      worker(NervesAps.Monitor.Loop, []),
      supervisor(Phoenix.PubSub.PG2, [Nerves.PubSub, [poolsize: 1]])
    ]

    opts = [strategy: :one_for_one, name: NervesAps.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
