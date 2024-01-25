defmodule Client.Managers.Container do
  @moduledoc """
  Module for managing containers
  """

  alias ClientData.Apps
  alias ClientData.Containers
  alias ClientData.StateMachine, as: SM

  alias Client.Utils.Docker

  use GenServer

  @name :container_manager

  @newline_regex ~r/\r|\n/
  @container_regex ~r/^Container (.*) Creating$/

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    {:ok, nil}
  end

  def handle_cast({:create, app, config}, _state) do
    case app |> Apps.get_path() do
      {:ok, path} -> Task.start(fn -> create_containers(app, config, path) end)
      {:error, _reason} -> nil
    end

    {:noreply, nil}
  end

  ##########

  defp create_containers(app, %{"compose_file" => compose_file}, path) do
    {_app, errors} =
      Docker.compose_dry_run(path |> Path.join(compose_file))
      |> Enum.reduce({app, []}, &process_output/2)

    unless errors == [] do
      app |> SM.transition_to(Apps, :start_failed, %{errors: errors})
    end
  end

  defp process_output({:exit, {:status, 0}}, {_app, _errors}) do
    {nil, []}
  end

  defp process_output({:exit, {:status, _nonzero}}, {_app, errors}) do
    {nil, errors |> Enum.reverse()}
  end

  defp process_output({_, lines}, acc) do
    lines
    |> String.split(@newline_regex)
    |> Enum.reduce(acc, &process_output_line/2)
  end

  defp process_output_line(line, {app, errors}) do
    line = String.trim(line)

    if line != "" do
      IO.puts("[#{app.name}] #{line}")

      line =
        line
        |> String.replace("DRY-RUN MODE - ", "")
        |> String.trim()

      if Regex.match?(@container_regex, line) do
        [[_, container_name]] = Regex.scan(@container_regex, line)
        container_name = container_name |> String.trim()

        app |> Containers.create(%{name: container_name, use_dockerfile: false})
      end

      {app, [line | errors |> Enum.take(3)]}
    else
      {app, errors}
    end
  end
end
