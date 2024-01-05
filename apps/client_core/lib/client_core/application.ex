defmodule ClientCore.Application do
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
      # Starts a worker by calling: ClientCore.Worker.start_link(arg)
      # {ClientCore.Worker, arg}

      {ClientCore.Managers.Application, db},
      ClientCore.Managers.Repository
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClientCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
