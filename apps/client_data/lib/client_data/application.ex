defmodule ClientData.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClientData.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:client_data, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:client_data, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ClientData.PubSub}
      # Start the Finch HTTP client for sending emails
      # {Finch, name: ClientData.Finch}
      # Start a worker by calling: ClientData.Worker.start_link(arg)
      # {ClientData.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ClientData.Supervisor)
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
