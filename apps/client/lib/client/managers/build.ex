defmodule Client.Managers.Build do
  @moduledoc """
  Module for managing Builds.
  """

  use GenServer

  alias Ecto.Changeset

  alias Client.Utils.Docker

  alias ClientData.Apps
  alias ClientData.Containers
  alias ClientData.Entities.App
  alias ClientData.Entities.Container
  alias ClientData.StateMachine, as: SM

  @name :build_manager

  @newline_regex ~r/\r|\n/
  @step_regex ~r/\b(FROM|RUN|COPY|WORKDIR)\b/

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    {:ok, nil}
  end

  def handle_cast({:build, container, app}, _state) do
    Task.start_link(fn -> start_building(container, app) end)

    {:noreply, nil}
  end

  ##########

  defp start_building(container, app) do
    case container |> SM.transition_to(Containers, :building) do
      {:ok, container} -> build_container(container, app)
      {:error, reason} -> mark_build_failed(container, reason)
    end
  end

  defp build_container(%Container{name: name} = container, %App{dockerfile: dockerfile} = app) do
    case Apps.get_path(app) do
      {:ok, path} ->
        total_steps = Docker.get_build_steps(path, dockerfile)

        _ =
          Docker.build(name, path, dockerfile)
          |> Enum.reduce({container, app, total_steps, %{}, nil, []}, &process_build_output/2)

      {:error, reason} ->
        mark_build_failed(container, reason)
    end
  end

  defp process_build_output(
         {:exit, {:status, 0}},
         {container, _app, _total_steps, _completed_steps, _progress, _errors}
       ) do
    container |> SM.transition_to(Containers, :starting, %{progress: nil, errors: []})

    {0, %{}, nil, []}
  end

  defp process_build_output(
         {:exit, {:status, _nonzero}},
         {container, _app, _total_steps, _completed_steps, _progress, errors}
       ) do
    mark_build_failed(container, Enum.reverse(errors))

    {0, %{}, nil, []}
  end

  defp process_build_output({_, lines}, acc) do
    lines
    |> String.split(@newline_regex)
    |> Enum.reduce(acc, &process_output_line/2)
  end

  defp process_output_line(line, {container, app, total_steps, completed_steps, progress, errors}) do
    line = String.trim(line)

    if line != "" do
      updated_completed_steps = update_completed_steps(line, completed_steps)
      completed_steps_count = updated_completed_steps |> Map.keys() |> length()

      updated_progress = update_progress(completed_steps_count, total_steps)

      str_progress = "#{completed_steps_count}/#{total_steps} #{updated_progress}%"
      IO.puts("[#{app.name} > #{container.name}] (#{str_progress}) #{line}")

      errors = [line | errors |> Enum.take(3)]
      changeset = container |> Changeset.change(%{progress: "#{updated_progress}%"})

      case Containers.update(changeset) do
        {:ok, container} ->
          {container, app, total_steps, updated_completed_steps, updated_progress, errors}

        {:error, _reason} ->
          {container, app, total_steps, updated_completed_steps, updated_progress, errors}
      end
    else
      {container, app, total_steps, completed_steps, progress, errors}
    end
  end

  def update_completed_steps(line, completed_steps) do
    case Regex.run(@step_regex, line) do
      nil -> completed_steps
      _ -> completed_steps |> Map.put(line, true)
    end
  end

  defp update_progress(completed_steps, total_steps) do
    max(0, min((completed_steps / total_steps * 100) |> trunc(), 100))
  end

  defp mark_build_failed(container, reason) when is_binary(reason) do
    container |> SM.transition_to(Containers, :build_failed, %{errors: [reason]})
  end

  defp mark_build_failed(container, errors) do
    container |> SM.transition_to(Containers, :build_failed, %{errors: errors})
  end
end
