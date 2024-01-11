defmodule Client.Managers.Execution do
  @moduledoc """
  Module for managing the execution of applications.
  """
  use GenServer

  alias Client.Utils.Docker
  alias Client.Api.Application
  alias Client.Managers.Helpers
  alias Client.Entities.Application, as: App

  @name :execution_manager

  @newline_regex ~r/\r|\n/

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    process_starting(db)

    {:ok, db}
  end

  def handle_info({:process, :starting}, db) do
    process_starting(db)

    {:noreply, db}
  end

  ##########

  defp process_starting(db) do
    {:ok, apps} = Application.get_with_state(:starting)
    {docker_apps, _simplerun_apps} = apps |> Helpers.chunk_by_category()

    actively_starting = db |> Helpers.get_active(:starting) |> Enum.to_list()

    _ =
      docker_apps
      |> Stream.filter(fn %App{id: id} -> id not in actively_starting end)
      |> Enum.to_list()
      |> Enum.map(fn app -> Task.start(fn -> db |> start(app) end) end)

    self() |> Process.send_after({:process, :starting}, :timer.seconds(3))
  end

  defp start(db, %App{id: id} = app) do
    key = {:active, :starting, {id}}
    CubDB.put(db, key, true)

    try do
      {:ok, app} = app |> Application.inc_run_number()

      _ =
        Docker.run(app)
        |> Enum.reduce([], fn output, errors ->
          case output do
            {:exit, {:status, 0}} ->
              Application.set_state(app, :started)
              []

            {:exit, {:status, _nonzero}} ->
              Application.set_state(app, :start_failed, errors |> Enum.reverse())
              []

            {_, lines} ->
              lines
              |> String.split(@newline_regex)
              |> Enum.reduce(errors, fn line, errors ->
                if line |> String.trim() != "" do
                  IO.puts("[#{app.name}] #{line}")
                  [line | errors |> Enum.take(3)]
                end
              end)
          end
        end)
    after
      CubDB.delete(db, key)
    end
  end
end
