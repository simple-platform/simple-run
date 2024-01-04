defmodule ClientCore.Managers.Repository do
  @moduledoc """
  This module manages interactions with repositories.
  """
  use GenServer

  alias ClientCore.Entities.Application, as: App

  @name :repository_manager
  @app_manager :application_manager

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:clone, %App{url: url} = app}, state) do
    IO.puts("!!! Cloning repo: #{url} ...")

    GenServer.cast(@app_manager, {:update, %App{app | state: :cloning}})
    {:noreply, state}
  end
end
