import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :client, Client.Endpoint,
  url: [host: "localhost", port: 3156],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :actions, Actions.Endpoint,
  url: [host: "actions.run.simple.dev", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  cors_origin: ["https://simple.dev"],
  pixel_image_url: "https://simple.dev/run/pixel.png",
  button_image_url: "https://simple.dev/run/simple-run-locally@2x.png"

config :client, env: :prod
