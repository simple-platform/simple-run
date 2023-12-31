defmodule Client.Utils.Docker do
  @moduledoc """
  Module for managing Docker-related utilities.
  """

  require Logger
  alias Client.Entities.Application, as: App

  def get_status() do
    try do
      {get_version(), is_running()}
    rescue
      _ -> {nil, false}
    end
  end

  def dockerfile?(file) do
    !String.ends_with?(file, ".yml") && !String.ends_with?(file, ".yaml")
  end

  def build_dockerfile(%App{name: name, file_to_run: file, path: path}) do
    cmd = ~w(docker build -t #{name}:simplerun -f #{Path.join(path, file)} #{path})
    Logger.info("Executing command: #{Enum.join(cmd, " ")}")

    cmd |> Exile.stream(stderr: :consume)
  end

  def start_dockerfile(%App{name: _name, file_to_run: _file}) do
    # cmd = ~w(docker run -t #{name}:simplerun -f #{file} . --verbose)
  end

  def start_docker_compose(%App{file_to_run: file}) do
    IO.puts("!!! Starting Docker Compose: #{file}")
  end

  ##########

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
