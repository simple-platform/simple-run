defmodule Client.Managers.Repository do
  @moduledoc """
  This module manages interactions with repositories.
  """
  use GenServer

  alias Client.Utils.Git
  alias Client.Api.Application
  alias Client.Entities.Application, as: App

  @name :repository_manager
  @progress_regex ~r/(\d+)%/
  @newline_regex ~r/\r|\n/

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    clone_repos(db)

    {:ok, db}
  end

  def handle_info(:clone, db) do
    clone_repos(db)

    {:noreply, db}
  end

  ##########

  defp clone_repos(db) do
    active_clones = get_active_clones(db) |> Enum.to_list()

    {:ok, apps} = Application.get_with_state(:cloning)

    _ =
      apps
      |> Stream.filter(fn %App{id: id} -> id not in active_clones end)
      |> Enum.to_list()
      |> Enum.map(fn app -> Task.start(fn -> db |> clone(app) end) end)

    self() |> Process.send_after(:clone, :timer.seconds(3))
  end

  defp get_active_clones(db) do
    min_key = {:active, :clone, {}}
    max_key = {:active, :clone, {nil, nil}}

    db
    |> CubDB.select(min_key: min_key, max_key: max_key)
    |> Stream.map(fn {{:active, :clone, {id}}, _value} -> id end)
  end

  defp clone(db, %App{id: id, url: url, path: path} = app) do
    key = {:active, :clone, {id}}
    db |> CubDB.put(key, true)

    try do
      case Git.clone(url, path) do
        {:ok, stream} -> stream |> monitor_cloning(app)
        {:error, reason} -> app |> Application.set_state(:cloning_failed, reason)
      end
    after
      db |> CubDB.delete(key)
    end
  end

  defp monitor_cloning(stream, %App{name: name} = app) do
    Enum.reduce(stream, {0, 0, []}, fn
      {:exit, {:status, status}}, acc -> handle_exit(app, status, acc)
      {_, lines}, acc -> handle_lines(app, name, lines, acc)
    end)
  end

  defp handle_exit(app, 0, _), do: update_app_state(app, "100%", :scheduled, nil)

  defp handle_exit(app, _nonzero, {_, _, errors}),
    do: update_app_state(app, nil, :cloning_failed, errors |> Enum.reverse())

  defp handle_lines(app, name, lines, acc) do
    String.split(lines, @newline_regex)
    |> Enum.reduce(acc, &process_line(app, name, &1, &2))
  end

  defp process_line(app, name, line, {progress, prev_progress, errors}) do
    line
    |> String.trim()
    |> maybe_process_non_empty_line(app, name, {progress, prev_progress, errors})
  end

  defp maybe_process_non_empty_line("", _, _, acc), do: acc

  defp maybe_process_non_empty_line(line, app, name, {progress, prev_progress, errors}) do
    updated_progress = get_progress(line)
    total_progress = update_progress(progress, prev_progress, updated_progress)
    log_progress(app, name, line, total_progress)
    {total_progress, updated_progress, [line | errors |> Enum.take(3)]}
  end

  defp update_progress(progress, prev_progress, updated_progress) do
    if updated_progress != prev_progress,
      do: min(progress + updated_progress, 100),
      else: progress
  end

  defp log_progress(app, name, line, total_progress) do
    progress = "#{trunc(total_progress)}%"
    Application.set_progress(app, progress)
    IO.puts("[#{name}] (#{progress}) #{line}")
  end

  defp get_progress(line) do
    case Regex.run(@progress_regex, line) do
      [progress | _] -> calculate_progress(progress)
      _ -> 0
    end
  end

  defp calculate_progress(progress) do
    (progress |> String.replace("%", "") |> String.to_integer()) / 100 * 0.4
  end

  defp update_app_state(app, progress, state, errors) do
    Application.set_progress(app, progress)

    case is_list(errors) do
      false -> Application.set_state(app, state)
      true -> Application.set_state(app, state, Enum.reverse(errors))
    end

    {nil, nil, []}
  end
end
