defmodule Actions.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Actions.Telemetry,

      # Start the Endpoint (http/https)
      Actions.Endpoint,
      {Phoenix.PubSub, name: Actions.PubSub}

      # Start a worker by calling: Actions.Worker.start_link(arg)
      # {Actions.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Actions.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Actions.Endpoint.config_change(changed, removed)
    :ok
  end
end
