defmodule Client.Managers.Execution do
  @moduledoc """
  Module for managing the execution, including scheduled processing and building of applications.
  """
  use GenServer

  alias Client.Utils.Docker
  alias Client.Api.Application
  alias Client.Entities.Application, as: App

  @name :execution_manager

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    process_scheduled(db)

    {:ok, db}
  end

  def handle_info({:process, :scheduled}, db) do
    process_scheduled(db)

    {:noreply, db}
  end

  ##########

  defp process_scheduled(db) do
    {:ok, apps} = Application.get_with_state(:scheduled)
    {docker_apps, _compose_apps, _simplerun_apps} = apps |> chunk_by_category()

    active_builds = db |> get_active(:build) |> Enum.to_list()

    _ =
      docker_apps
      |> Stream.filter(fn %App{id: id} -> id not in active_builds end)
      |> Enum.to_list()
      |> Enum.map(fn app -> Task.start(fn -> db |> build(app) end) end)

    self() |> Process.send_after({:process, :scheduled}, :timer.seconds(1))
  end

  defp build(db, %App{id: id, name: name} = app) do
    app |> Application.set_state(:building)

    key = {:active, :build, {id}}
    db |> CubDB.put(key, true)

    _ =
      app
      |> Docker.build()
      |> Enum.reduce([], fn output, errors ->
        case output do
          {:exit, {:status, 0}} ->
            app |> Application.set_state(:starting)
            []

          {:exit, {:status, _nonzero}} ->
            app |> Application.set_state(:build_failed, errors |> Enum.reverse() |> Enum.take(3))
            []

          {_, line} ->
            IO.puts("[#{name}] #{line}")
            [line | errors]
        end
      end)

    db |> CubDB.delete(key)
  end

  defp get_active(db, state) do
    min_key = {:active, state, {}}
    max_key = {:active, state, {nil, nil}}

    db
    |> CubDB.select(min_key: min_key, max_key: max_key)
    |> Stream.map(fn {{:active, _state, {id}}, _value} -> id end)
  end

  defp chunk_by_category(apps) do
    apps
    |> Enum.reduce({[], [], []}, fn %App{file_to_run: file_to_run} = app,
                                    {docker, compose, simplerun} ->
      case get_category(file_to_run) do
        :docker -> {[app | docker], compose, simplerun}
        :compose -> {docker, [app | compose], simplerun}
        :simplerun -> {docker, compose, [app | simplerun]}
      end
    end)
  end

  defp get_category(nil), do: :simplerun

  defp get_category(file) do
    if String.ends_with?(file, ".yml") or String.ends_with?(file, ".yaml"),
      do: :compose,
      else: :docker
  end
end
