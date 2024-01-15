defmodule Client.Managers.Container do
  @moduledoc """
  Module for managing Containers.
  """

  use GenServer

  alias ClientData.Entities.App
  alias ClientData.Containers

  @name :container_manager

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(_init) do
    {:ok, nil}
  end

  ##########
end
