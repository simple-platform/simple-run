import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :client_data, ClientData.Repo,
  database: Path.expand("../.db/simplerun.test.sqlite", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :client, Client.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5002],
  secret_key_base: "2jl+nHzWWKvjJUzZNCLPHSBjIYWj9fuB7+QTKI4e67qLu0qzzAMWwr1VDd+ph3G8",
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :actions, Actions.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KQc8/FFHjT07NPfs1gvylW0kMBLHXtyHsU8mquvNE9Y+TdywKbv5WzMzyRAppBXL",
  server: false

config :actions, :http_client, Actions.HttpClientMock
config :actions, :github_provider, Actions.RepoProviderMock
