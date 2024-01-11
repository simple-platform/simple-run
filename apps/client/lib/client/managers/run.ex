defmodule Client.Managers.Run do
  @moduledoc """
  Module for managing the run of applications.
  """
  use GenServer

  alias Client.Utils.Docker
  alias Client.Api.Application
  alias Client.Managers.Helpers
  alias Client.Entities.Application, as: App

  @name :run_manager

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    process_started(db)

    {:ok, db}
  end

  def handle_info({:process, :started}, db) do
    process_started(db)

    {:noreply, db}
  end

  ##########

  defp process_started(db) do
    {:ok, apps} = Application.get_with_state(:started)
    {docker_apps, _simplerun_apps} = apps |> Helpers.chunk_by_category()

    actively_mapping_ports = db |> Helpers.get_active(:mapping_ports) |> Enum.to_list()

    _ =
      docker_apps
      |> Stream.filter(fn %App{id: id} -> id not in actively_mapping_ports end)
      |> Enum.to_list()
      |> Enum.map(fn app -> Task.start(fn -> db |> map_ports(app) end) end)

    self() |> Process.send_after({:process, :started}, :timer.seconds(3))
  end

  defp map_ports(db, %App{id: id} = app) do
    key = {:active, :mapping_ports, {id}}
    CubDB.put(db, key, true)

    try do
      docker_config = Docker.inspect(app) |> Enum.at(0)
      ports = docker_config["NetworkSettings"]["Ports"]

      port_map =
        ports
        |> Map.keys()
        |> Enum.map(fn key ->
          [port, _] = key |> String.split("/")

          port_binding = ports[key]

          if length(port_binding) > 0 do
            binding = port_binding |> Enum.at(0)

            ip = binding["HostIp"]
            local_port = binding["HostPort"]

            {port, {ip, local_port}, http?(ip, local_port)}
          else
            {port, nil}
          end
        end)

      {:ok, app} = app |> Application.set_ports(port_map)
      app |> Application.set_state(:running)
    after
      CubDB.delete(db, key)
    end
  end

  defp http?(ip, port) do
    case :httpc.request(:get, {"http://#{ip}:#{port}", []}, [], []) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
