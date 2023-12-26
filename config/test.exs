import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :actions, Actions.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "IOuzw29dStYzsq4YnrS+NfcBNCR9TICD9i4XMtVyR84aye15paOGTcZJGjSvXAO1",
  server: false

config :actions, :http_client, Actions.HttpClientMock
config :actions, :github_provider, Actions.RepoProviderMock
