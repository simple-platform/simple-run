defmodule Client.Managers.Run do
  @moduledoc """
  This module manages the running of containers.
  """

  alias Ecto.Changeset

  alias Client.Utils.Docker

  alias ClientData.Containers
  alias ClientData.Entities.Container
  alias ClientData.StateMachine, as: SM

  use GenServer

  @name :run_manager

  @newline_regex ~r/\r|\n/

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    {:ok, nil}
  end

  def handle_cast({:run, container}, _state) do
    if container.use_dockerfile do
      Task.start(fn -> run_container(container) end)
    end

    {:noreply, nil}
  end

  def handle_cast({:map_ports, container}, _state) do
    if container.state == :running do
      Task.start(fn -> map_ports(container) end)
    end

    {:noreply, nil}
  end

  ##########

  defp map_ports(%Container{name: name} = container) do
    port_map =
      Docker.inspect(name)
      |> Enum.at(0)
      |> Map.get("NetworkSettings")
      |> Map.get("Ports")
      |> Map.to_list()
      |> Enum.map(&build_port_map/1)

    container
    |> Changeset.change(%{ports: port_map})
    |> Containers.update()
  end

  defp build_port_map({port_key, port_bindings}) do
    [port, proto] = port_key |> String.split("/")

    local =
      if (port_bindings || []) != [] do
        binding = port_bindings |> Enum.at(0)

        local_ip = binding["HostIp"]
        local_port = binding["HostPort"]

        %{
          "ip" => local_ip,
          "port" => local_port,
          "is_http" => http_service?(local_ip, local_port)
        }
      else
        %{}
      end

    %{"port" => port, "proto" => proto, "local" => local}
  end

  defp http_service?(ip, port) do
    case :httpc.request(:get, {"http://#{ip}:#{port}", []}, [], []) do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp run_container(%Container{name: name} = container) do
    Docker.remove(name)

    _ =
      Docker.run(name)
      |> Enum.reduce({container, []}, &process_output/2)
  end

  defp process_output({:exit, {:status, 0}}, {container, _errors}) do
    container |> SM.transition_to(Containers, :running, %{errors: []})
    {nil, []}
  end

  defp process_output({:exit, {:status, _nonzero}}, {container, errors}) do
    container |> SM.transition_to(Containers, :run_failed, %{errors: errors |> Enum.reverse()})
    {nil, []}
  end

  defp process_output({_, lines}, acc) do
    lines
    |> String.split(@newline_regex)
    |> Enum.reduce(acc, &process_output_line/2)
  end

  defp process_output_line(line, {container, errors}) do
    line = String.trim(line)

    if line != "" do
      {container, [line | errors |> Enum.take(3)]}
    else
      {container, errors}
    end
  end
end
