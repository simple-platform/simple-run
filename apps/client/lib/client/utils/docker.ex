defmodule Client.Utils.Docker do
  @moduledoc """
  Module for managing Docker-related utilities.
  """

  require Logger
  alias Client.Entities.Application, as: App

  @step_commands ["FROM", "RUN", "COPY", "WORKDIR"]

  def get_status() do
    try do
      {get_version(), is_running()}
    catch
      _ -> {nil, false}
    end
  end

  def build(%App{name: name, file_to_run: file, path: path}) do
    cmd =
      ~w(docker build --progress=plain -t #{name}:simplerun -f #{Path.join(path, file)} #{path})

    Logger.info("Executing command: #{Enum.join(cmd, " ")}")

    cmd |> Exile.stream(stderr: :consume)
  end

  def run(%App{name: name, org: org, repo: repo, run_number: run_number}) do
    cmd = ~w(docker run -d -P --name sr-#{org}-#{repo}-#{run_number} #{name}:simplerun)

    Logger.info("Executing command: #{Enum.join(cmd, " ")}")

    cmd |> Exile.stream(stderr: :consume)
  end

  def inspect(%App{org: org, repo: repo, run_number: run_number}) do
    cmd = ~w(docker inspect sr-#{org}-#{repo}-#{run_number})

    Logger.info("Executing command: #{Enum.join(cmd, " ")}")

    cmd
    |> Exile.stream!()
    |> Enum.into("")
    |> Jason.decode!()
  end

  def get_build_steps(%App{file_to_run: file, path: path}) do
    {:ok, cwd} = File.cwd()

    df_json =
      (Application.get_env(:client, :app_path) || cwd)
      |> resolve_df_json_path()

    cmd = [df_json, Path.join(path, file)]

    Logger.info("Executing command: #{Enum.join(cmd, " ")}")
    stages = parse_dockerfile_stages(cmd)

    Enum.reduce(stages, length(stages), &count_stage_steps/2)
  end

  ##########

  defp resolve_df_json_path(app_path) do
    case app_path |> String.contains?("Simple Run.app") do
      true ->
        Path.join(app_path, "dockerfile-json")

      false ->
        Path.join(app_path, "sidecars/dockerfile-json-1.0.8/dockerfile-json-x86_64-apple-darwin")
    end
  end

  defp parse_dockerfile_stages(cmd) do
    cmd
    |> Exile.stream!()
    |> Enum.into("")
    |> Jason.decode!()
    |> Map.get("Stages")
  end

  defp count_stage_steps(%{"Commands" => commands}, total_steps) do
    stage_steps = Enum.count(commands, &command_step?/1)
    total_steps + stage_steps
  end

  defp command_step?(%{"Name" => name}), do: name in @step_commands

  defp get_version() do
    Exile.stream(["docker", "-v"], stderr: :consume)
    |> Enum.reduce(nil, fn
      {:exit, {:status, 0}}, version -> version
      {:exit, {:status, _}}, _version -> nil
      {_, version}, _version -> version
    end)
  end

  defp is_running() do
    Exile.stream(["docker", "ps"], stderr: :consume)
    |> Enum.reduce(false, fn
      {:exit, {:status, 0}}, _running -> true
      _, _running -> false
    end)
  end
end
