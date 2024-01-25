defmodule Client.Utils.Docker do
  @moduledoc """
  Module for interacting with Docker.
  """

  @step_commands ["FROM", "RUN", "COPY", "WORKDIR"]

  def get_status() do
    try do
      _ = ~w(docker ps) |> Exile.stream!() |> Enum.into("")

      {true, true}
    rescue
      _ in Exile.Stream.AbnormalExit -> {true, false}
      _ -> {false, false}
    end
  end

  def start() do
    try do
      _ = ~w(open /Applications/Docker.app) |> Exile.stream!() |> Enum.into("")
    rescue
      _ -> :ok
    end
  end

  def build(name, path, dockerfile) do
    ~w(docker build --progress=plain -t #{name}:simplerun -f #{Path.join(path, dockerfile)} #{path})
    |> Exile.stream(stderr: :consume)
  end

  def remove(name) do
    ~w(docker rm -f #{name})
    |> Exile.stream!()
    |> Enum.into("")
  end

  def run(name) do
    ~w(docker run -d -P --name #{name} #{name}:simplerun)
    |> Exile.stream(stderr: :consume)
  end

  def inspect(name) do
    ~w(docker inspect #{name})
    |> Exile.stream!()
    |> Enum.into("")
    |> Jason.decode!()
  end

  def compose_dry_run(path) do
    ~w(docker compose -f #{path} up --dry-run)
    |> Exile.stream(stderr: :consume)
  end

  def get_build_steps(path, dockerfile) do
    cwd = File.cwd!()

    df_json =
      Application.get_env(:client, :app_path, cwd)
      |> resolve_df_json_path()

    stages =
      [df_json, path |> Path.join(dockerfile)]
      |> Exile.stream!()
      |> Enum.into("")
      |> Jason.decode!()
      |> Map.get("Stages")

    stages |> Enum.reduce(length(stages), &count_stage_steps/2)
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

  defp count_stage_steps(%{"Commands" => commands}, total_steps) do
    total_steps + Enum.count(commands, &command_step?/1)
  end

  defp command_step?(%{"Name" => name}), do: name in @step_commands
end
