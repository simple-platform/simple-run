defmodule Client.Managers.Docker do
  @moduledoc """
  Module for managing Docker.
  """

  alias Client.Utils.Docker

  use GenServer

  @name :docker_manager

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    refresh_status()
    {:ok, nil}
  end

  def handle_info(:refresh_status, _state) do
    refresh_status()
    {:noreply, nil}
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(ClientData.PubSub, "docker")
  end

  ##########

  defp refresh_status() do
    {installed, running} = Docker.get_status()

    if installed && !running do
      Docker.start()
    end

    broadcast({:docker_status, %{installed: installed, running: running}})

    self() |> Process.send_after(:refresh_status, :timer.seconds(3))
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "docker", message)
  end
end
