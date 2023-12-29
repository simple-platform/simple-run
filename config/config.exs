# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

web_endpoint = System.get_env("SIMPLE_RUN_WEB_ENDPOINT", "http://localhost:3000")

config :actions,
  generators: [context_app: false]

# Configures the endpoint
config :actions, Actions.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: Actions.ErrorJSON],
    layout: false
  ],
  pubsub_server: Actions.PubSub,
  live_view: [signing_salt: "aBaJbjtV"]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Enable dev routes for dashboard and mailbox
config :actions, dev_routes: true

config :actions, cors_origin: [web_endpoint]

config :actions, :pixel_image_url, "#{web_endpoint}/run/pixel.png"

config :actions, :button_image_url, "#{web_endpoint}/run/simple-run-locally@2x.png"

config :actions, :github_token, System.get_env("SIMPLE_RUN_GH_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
