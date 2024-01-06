defmodule Client.Managers.Container.State do
  @moduledoc """
  Module for managing the state of the container, including Docker installation and running status.
  """
  defstruct [:docker_version, :docker_running]
end

defmodule Client.Managers.Container do
  use GenServer

  alias Client.Utils.Docker
  alias Client.Managers.Container.State

  @name :container_manager

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_state) do
    {version, running} = refresh_docker_status()
    {:ok, %State{docker_version: version, docker_running: running}}
  end

  def handle_info({:refresh, :docker_status}, state) do
    {version, running} = refresh_docker_status()
    {:noreply, %State{state | docker_version: version, docker_running: running}}
  end

  ##########

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(Client.PubSub, "container", message)
  end

  defp refresh_docker_status() do
    status = Docker.get_status()

    broadcast({:docker_status, status})
    self() |> Process.send_after({:refresh, :docker_status}, :timer.seconds(10))

    status
  end
end
