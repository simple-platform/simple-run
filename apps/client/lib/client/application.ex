defmodule Client.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, db} =
      CubDB.start_link(
        name: :db,
        auto_compact: true,
        auto_file_sync: true,
        data_dir: System.user_home!() |> Path.join(".simple/run/data")
      )

    children = [
      Client.Telemetry,
      {Phoenix.PubSub, name: Client.PubSub},
      {Client.Managers.Application, db},
      {Client.Managers.Repository, db},
      {Client.Managers.Execution, db},
      Client.Managers.Container,

      # Start to serve requests, typically the last entry
      Client.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Client.Endpoint.config_change(changed, removed)
    :ok
  end
end
