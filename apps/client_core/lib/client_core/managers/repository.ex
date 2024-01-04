defmodule ClientCore.Managers.Repository do
  @moduledoc """
  This module manages interactions with repositories.
  """
  alias ClientCore.Entities.Application
  use GenServer

  @name :repository_manager

  def start_link(_state) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:clone, %Application{url: url} = _app}, _from, state) do
  end
end
