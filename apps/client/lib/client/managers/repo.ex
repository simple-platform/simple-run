defmodule Client.Managers.Repo do
  @moduledoc """
  Module for managing Repos.
  """

  use GenServer

  alias Ecto.Changeset

  alias Client.Utils.Git
  alias ClientData.Apps
  alias ClientData.Entities.App

  alias ClientData.StateMachine, as: SM

  @name :repo_manager

  @newline_regex ~r/\r|\n/
  @progress_regex ~r/(\d+)%/

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    {:ok, nil}
  end

  def handle_cast({:clone, app}, _state) do
    Task.start_link(fn -> start_cloning(app) end)

    {:noreply, nil}
  end

  ##########

  defp start_cloning(app) do
    case app |> SM.transition_to(Apps, :cloning) do
      {:ok, app} ->
        clone_repo(app)

      {:error, reason} ->
        app |> SM.transition_to(Apps, :cloning_failed, %{errors: [reason]})
    end
  end

  defp clone_repo(%App{url: url} = app) do
    with {:ok, path} <- Apps.get_path(app),
         {:ok, stream} <- Git.clone(url, path) do
      _ =
        stream
        |> Enum.reduce({app, 0, 0, []}, &process_clone_output/2)
    else
      {:error, reason} ->
        app |> SM.transition_to(Apps, :cloning_failed, %{errors: [reason]})
    end
  end

  defp process_clone_output({:exit, {:status, 0}}, {app, _progress, _prev_progress, _errors}) do
    app |> SM.transition_to(Apps, :starting, %{progress: nil, errors: []})
    {nil, 0, 0, []}
  end

  defp process_clone_output(
         {:exit, {:status, _nonzero}},
         {app, _progress, _prev_progress, errors}
       ) do
    app |> SM.transition_to(Apps, :cloning_failed, %{errors: Enum.reverse(errors)})
    {nil, 0, 0, []}
  end

  defp process_clone_output({_, lines}, acc) do
    lines
    |> String.split(@newline_regex)
    |> Enum.reduce(acc, &process_line/2)
  end

  defp process_line(line, {app, progress, prev_progress, errors}) do
    line = String.trim(line)

    if line != "" do
      step_progress = calculate_progress(line)
      new_progress = update_progress(progress, prev_progress, step_progress)

      str_progress = "#{trunc(new_progress)}%"
      IO.puts("[#{app.name}] (#{str_progress}) #{line}")

      errors = [line | errors |> Enum.take(3)]
      changeset = app |> Changeset.change(%{progress: str_progress})

      case Apps.update(changeset) do
        {:ok, app} -> {app, new_progress, step_progress, errors}
        {:error, _reason} -> {app, new_progress, step_progress, errors}
      end
    else
      {app, progress, prev_progress, errors}
    end
  end

  def calculate_progress(line) do
    case Regex.run(@progress_regex, line) do
      [text | _] -> extract_progress(text) / 100 * 0.4
      _ -> 0
    end
  end

  defp extract_progress(text) do
    text |> String.replace("%", "") |> String.to_integer()
  end

  def update_progress(progress, prev_progress, step_progress) do
    if prev_progress != step_progress, do: min(progress + step_progress, 100), else: progress
  end
end
