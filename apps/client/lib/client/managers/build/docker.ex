defmodule Client.Managers.Build.Docker do
  @moduledoc """
  Module for managing the Docker build process.
  """
  use GenServer

  alias Client.Utils.Docker
  alias Client.Api.Application
  alias Client.Entities.Application, as: App

  @name :docker_build_manager

  @step_regex ~r/\b(FROM|RUN|COPY|WORKDIR)\b/
  @newline_regex ~r/\r|\n/

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    {:ok, db}
  end

  def handle_cast({:build, %App{id: id} = app}, db) do
    active_build = db |> CubDB.get({:active, :docker_build, {id}})

    if is_nil(active_build) do
      key = {:active, :docker_build, {id}}
      CubDB.put(db, key, true)

      Task.start_link(fn ->
        try do
          build(app)
        after
          CubDB.delete(db, key)
        end
      end)
    end

    {:noreply, db}
  end

  ##########

  defp build(app) do
    {:ok, app} = Application.set_state(app, :building)

    total_steps = Docker.get_build_steps(app)

    _ =
      Docker.build(app)
      |> Enum.reduce({0, nil, []}, fn output, acc ->
        process_output(output, acc, app, total_steps)
      end)
  end

  defp process_output({:exit, {:status, status}}, _acc, app, _steps) when status == 0 do
    Application.set_state(app, :starting)
    {nil, []}
  end

  defp process_output({:exit, {:status, _nonzero}}, {_, _, errors}, app, _steps) do
    Application.set_state(app, :build_failed, errors |> Enum.reverse())
    {nil, []}
  end

  defp process_output({_, output}, acc, app, total_steps) do
    output
    |> String.split(@newline_regex)
    |> Enum.reduce(acc, fn line, acc ->
      process_line(line, acc, app, total_steps)
    end)
  end

  defp process_line(line, {completed_steps, progress, errors}, app, total_steps) do
    line = String.trim(line)

    if line != "" do
      new_completed_steps = update_completed_steps(completed_steps, line)
      updated_progress = update_progress(new_completed_steps, total_steps)

      maybe_update_progress(app, updated_progress, progress)
      IO.puts(format_progress_line(app, updated_progress, line))

      {new_completed_steps, updated_progress, [line | errors |> Enum.take(3)]}
    else
      {completed_steps, progress, errors}
    end
  end

  defp maybe_update_progress(app, updated_progress, progress) do
    if updated_progress != progress, do: Application.set_progress(app, "#{updated_progress}%")
  end

  defp format_progress_line(app, updated_progress, line) do
    "[#{app.name}] (#{updated_progress}%) #{line}"
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
end
