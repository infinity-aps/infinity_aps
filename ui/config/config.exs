use Mix.Config

import_config Path.expand("../aps/config/config.exs")

config :ui, namespace: InfinityAPS.UI

# Configures the endpoint
config :ui, InfinityAPS.UI.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4ThSx+plS42YVDI5CbtAWAEeDya+fGWKqf/lfi0W0cCxoo/QdQY+udiHdRI8rVfi",
  render_errors: [view: InfinityAPS.UI.ErrorView, accepts: ~w(html json)],
  pubsub: [name: InfinityAPS.UI.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env()}.exs"
