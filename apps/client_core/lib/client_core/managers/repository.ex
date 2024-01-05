defmodule ClientCore.Managers.Repository do
  @moduledoc """
  This module manages interactions with repositories.
  """
  use GenServer

  alias ClientCore.Utils.Git
  alias ClientCore.Api.Applications
  alias ClientCore.Entities.Application, as: App

  @name :repository_manager

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:clone, %App{url: url, path: path} = app}, state) do
    {:ok, app} = app |> Applications.set_state(:cloning)

    case Git.clone(url, path) do
      :ok -> app |> Applications.start()
      {:error, reason} -> app |> Applications.set_state(:cloning_failed, reason)
    end

    {:noreply, state}
  end
end
