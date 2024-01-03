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

config :client,
  generators: [context_app: false]

# Configures the endpoint
config :client, Client.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: Client.ErrorHTML, json: Client.ErrorJSON],
    layout: false
  ],
  pubsub_server: Client.PubSub,
  live_view: [signing_salt: "MEho23Jd"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.19.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --external:/css/*),
    cd: Path.expand("../apps/client/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.5",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/client/assets", __DIR__)
  ]

web_endpoint = System.get_env("SIMPLE_RUN_WEB_ENDPOINT", "http://localhost:3000")

config :actions,
  generators: [context_app: false]

# Configures the endpoint
config :actions, Actions.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: Actions.ErrorJSON],
    layout: false
  ],
  pubsub_server: Actions.PubSub,
  live_view: [signing_salt: "1yUQh1yW"]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#
import Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Enable dev routes for dashboard
config :actions, dev_routes: true

config :actions, cors_origin: [web_endpoint]

config :actions, :pixel_image_url, "#{web_endpoint}/run/pixel.png"

config :actions, :button_image_url, "#{web_endpoint}/run/simple-run-locally@2x.png"

config :actions, :github_token, System.get_env("SIMPLE_RUN_GH_TOKEN")

config :ex_tauri,
  version: "1.5.4",
  app_name: "Simple Run",
  host: "localhost",
  port: 3156

config :ex_heroicons, type: "outline"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
