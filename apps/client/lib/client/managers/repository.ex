defmodule Client.Managers.Repository do
  @moduledoc """
  This module manages interactions with repositories.
  """
  use GenServer

  alias Client.Utils.Git
  alias Client.Api.Applications
  alias Client.Entities.Application, as: App

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
      {:ok, stream} -> stream |> monitor_cloning(app)
      {:error, reason} -> app |> Applications.set_state(:cloning_failed, reason)
    end

    {:noreply, state}
  end

  # https://github.com/simple-platform/simple-run

  defp monitor_cloning(stream, app) do
    Enum.reduce(stream, [], fn output, errors ->
      case output do
        {:stderr, line} ->
          [line | errors]

        {:exit, {:status, 0}} ->
          app |> Applications.start()
          []

        {:exit, {:status, _nonzero}} ->
          error = errors |> Enum.reverse() |> Enum.join(" ")
          app |> Applications.set_state(:cloning_failed, error)
          []
      end
    end)
  end
end
