defmodule InfinityAPS.Configuration.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {InfinityAPS.Configuration.Server,
       [
         Keyword.get(Application.get_env(:aps, InfinityAPS.Configuration), :file)
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
