# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ui,
  namespace: InfinityAPS.UI

# Configures the endpoint
config :ui, InfinityAPS.UI.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4ThSx+plS42YVDI5CbtAWAEeDya+fGWKqf/lfi0W0cCxoo/QdQY+udiHdRI8rVfi",
  render_errors: [view: InfinityAPS.UI.ErrorView, accepts: ~w(html json)],
  pubsub: [name: InfinityAPS.UI.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :cfg, InfinityAPS.Configuration,
  file: "#{File.cwd!}/../host_config.json"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
