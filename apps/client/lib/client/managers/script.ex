defmodule Client.Managers.Script do
  @moduledoc """
  This module defines the GenServer for managing scripts.
  """

  alias ClientData.Apps
  alias ClientData.Scripts
  alias ClientData.Entities.Script
  alias ClientData.StateMachine, as: SM

  use GenServer

  @name :script_manager

  @newline_regex ~r/\r|\n/

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    {:ok, nil}
  end

  def handle_call({:run, app, scripts}, _from, state) do
    case app |> Apps.get_path() do
      {:ok, path} -> run_scripts(app, path, scripts)
      {:error, _reason} -> nil
    end

    {:reply, :ok, state}
  end

  ##########

  defp run_scripts(app, path, scripts) do
    scripts
    |> Enum.each(fn %Script{file: file, type: type} = script ->
      case script |> SM.transition_to(Scripts, :running) do
        {:ok, script} ->
          run_script(app, script, path)

        {:error, reason} ->
          script
          |> SM.transition_to(Scripts, :failed, [
            "Unable to run #{type} script #{file}: #{reason}"
          ])
      end
    end)
  end

  defp run_script(app, script, path) do
    _ =
      ~w(/bin/sh -c #{Path.join(path, script.file)})
      |> Exile.stream(stderr: :consume)
      |> Enum.reduce({app, script, []}, &process_output/2)
  end

  defp process_output({:exit, {:status, 0}}, {_app, script, _errors}) do
    script |> SM.transition_to(Scripts, :success)
    {nil, nil, []}
  end

  defp process_output({:exit, {:status, _nonzero}}, {_app, script, errors}) do
    script |> SM.transition_to(Scripts, :failed, %{errors: errors |> Enum.reverse()})
    {nil, nil, []}
  end

  defp process_output({_, lines}, acc) do
    lines
    |> String.split(@newline_regex)
    |> Enum.reduce(acc, &process_output_line/2)
  end

  defp process_output_line(line, {app, script, errors}) do
    line = String.trim(line)

    if line != "" do
      IO.puts("[#{app.name} > #{script.file}] (#{script.order} / #{script.type}) #{line}")
      {app, script, [line | errors |> Enum.take(3)]}
    else
      {app, script, errors}
    end
  end
end
