defmodule Client.Managers.Repo do
  use GenServer

  alias Client.Utils.Git
  alias Client.Entities.App

  @name :repo_manager

  @newline_regex ~r/\r|\n/
  @progress_regex ~r/(\d+)%/

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    clone_repos()
    {:ok, nil}
  end

  def handle_info(:clone, _state) do
    clone_repos()
    {:noreply, nil}
  end

  ##########

  defp clone_repos() do
    App.get_all()
    |> Stream.filter(fn %App{state: state} -> state == "registered" end)
    |> Enum.each(&start_cloning/1)

    self() |> Process.send_after(:clone, :timer.seconds(3))
  end

  defp start_cloning(app) do
    case app |> Machinery.transition_to(App, "cloning") do
      {:ok, app} ->
        Task.start_link(fn -> clone_repo(app) end)

      {:error, reason} ->
        app |> Machinery.transition_to(App, "cloning failed", %{errors: [reason]})
    end
  end

  defp clone_repo(%App{provider: provider, name: name, url: url} = app) do
    with {:ok, repo_root} <- get_repo_root(provider),
         path <- System.user_home!() |> Path.join("simplerun/#{repo_root}/#{name}"),
         {:ok, stream} <- Git.clone(url, path) do
      _ =
        stream
        |> Enum.reduce({app, 0, 0, []}, &process_clone_output/2)
    else
      {:error, reason} ->
        app |> Machinery.transition_to(App, "cloning failed", %{errors: [reason]})
    end
  end

  defp process_clone_output({:exit, {:status, 0}}, {app, _progress, _prev_progress, _errors}) do
    {App.update(%App{app | progress: nil, errors: []}), 0, 0, []}
  end

  defp process_clone_output(
         {:exit, {:status, _nonzero}},
         {app, _progress, _prev_progress, errors}
       ) do
    {App.update(%App{app | errors: Enum.reverse(errors)}), 0, 0, []}
  end

  defp process_clone_output({_, lines}, {app, progress, prev_progress, errors}) do
    {app, progress, prev_progress, errors} =
      lines
      |> String.split(@newline_regex)
      |> Enum.reduce({app, progress, prev_progress, errors}, &process_line/2)

    {app, progress, prev_progress, errors}
  end

  defp process_line(line, {app, progress, prev_progress, errors}) do
    line = String.trim(line)

    if line != "" do
      step_progress = calculate_progress(line)
      new_progress = update_progress(progress, prev_progress, step_progress)

      str_progress = "#{trunc(new_progress)}%"
      IO.puts("[#{app.name}] (#{str_progress}) #{line}")

      app = App.update(%App{app | progress: str_progress})
      {app, new_progress, step_progress, [line | errors |> Enum.take(3)]}
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

  defp get_repo_root(:github), do: {:ok, "github.com"}
  defp get_repo_root(provider), do: {:error, "Unknown provider: #{provider}"}
end
