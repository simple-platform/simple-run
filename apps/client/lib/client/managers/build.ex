defmodule Client.Managers.Build do
  @moduledoc """
  Module for managing the build, including scheduled processing and building of applications.
  """
  use GenServer

  alias Client.Api.Application
  alias Client.Managers.Helpers

  @name :build_manager

  @docker_builder :docker_build_manager

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(state) do
    process_scheduled()

    {:ok, state}
  end

  def handle_info({:process, :scheduled}, state) do
    process_scheduled()

    {:noreply, state}
  end

  ##########

  defp process_scheduled() do
    {:ok, apps} = Application.get_with_state(:scheduled)
    {docker_apps, _compose_apps, _simplerun_apps} = apps |> Helpers.chunk_by_category()

    _ =
      docker_apps
      |> Enum.map(fn app -> GenServer.cast(@docker_builder, {:build, app}) end)

    self() |> Process.send_after({:process, :scheduled}, :timer.seconds(3))
  end
end
