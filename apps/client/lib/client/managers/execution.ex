defmodule Client.Managers.Execution do
  @moduledoc """
  Module for managing the execution, including scheduled processing and building of applications.
  """
  use GenServer

  alias Client.Utils.Docker
  alias Client.Api.Application
  alias Client.Entities.Application, as: App

  @name :execution_manager

  @step_regex ~r/\b(FROM|RUN|COPY|WORKDIR)\b/

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
      |> Enum.map(fn app -> Task.start_link(fn -> db |> build(app) end) end)

    self() |> Process.send_after({:process, :scheduled}, :timer.seconds(1))
  end

  defp build(db, %App{id: id} = app) do
    {:ok, app} = Application.set_state(app, :building)

    key = {:active, :build, {id}}
    CubDB.put(db, key, true)

    total_steps = Docker.get_build_steps(app)

    _ =
      Docker.build(app)
      |> Enum.reduce({0, nil, []}, fn output, acc ->
        process_output(output, acc, app, total_steps)
      end)

    CubDB.delete(db, key)
  end

  defp process_output({:exit, {:status, status}}, _, app, _) when status == 0 do
    Application.set_state(app, :starting)
    {nil, []}
  end

  defp process_output({:exit, {:status, _nonzero}}, {_, _, errors}, app, _) do
    Application.set_state(app, :build_failed, errors |> Enum.take(3) |> Enum.reverse())
    {nil, []}
  end

  defp process_output({_, line}, {completed_steps, progress, errors}, app, total_steps) do
    line = String.trim(line)

    if line != "" do
      new_completed_steps = update_completed_steps(completed_steps, line)
      updated_progress = update_progress(new_completed_steps, total_steps)

      if updated_progress != progress, do: Application.set_progress(app, "#{updated_progress}%")
      IO.puts("[#{app.name}] (#{updated_progress}%) #{line}")

      {new_completed_steps, updated_progress, [line | errors]}
    else
      {completed_steps, progress, errors}
    end
  end

  defp update_completed_steps(completed_steps, line) do
    case Regex.run(@step_regex, line) do
      nil -> completed_steps
      _ -> completed_steps + 1
    end
  end

  defp update_progress(completed_steps, total_steps) do
    min((completed_steps / total_steps * 100) |> trunc(), 100)
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
