# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

import_config "#{Mix.Project.config()[:target]}.exs"

config :logger, backends: [RingLogger]

config :logger, RingLogger, max_size: 100
