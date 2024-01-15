defmodule ClientData.Containers do
  @moduledoc """
  This module provides functionality for managing containers.
  """

  alias Ecto.Changeset

  alias ClientData.StateMachine
  alias ClientData.Repo
  alias ClientData.Entities.Container

  use StateMachine,
    states: [:scheduled, :building, :build_failed, :starting, :running, :run_failed, :stopped],
    transitions: %{
      scheduled: [:building],
      building: [:build_failed, :starting],
      starting: [:running],
      running: [:run_failed, :stopped]
    }

  def get_all() do
    Repo.all(Container)
  end

  def create(app, container) do
    changeset =
      app
      |> Ecto.build_assoc(:containers)
      |> Container.changeset(container)

    case Repo.insert(changeset) do
      {:ok, container} ->
        broadcast({:container_created, container})
        GenServer.cast(:build_manager, {:build, container, app})
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  def update(changeset) do
    case Repo.update(changeset) do
      {:ok, container} ->
        broadcast({:container_updated, container})
        {:ok, container}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def persist_state_change(container, next_state, metadata) do
    changeset = container |> Changeset.change(%{state: next_state} |> Map.merge(metadata))
    update(changeset)
  end

  def pre_transition(container, _next_state, _metadata) do
    {:ok, container}
  end

  def post_transition(_container, _state, _metadata) do
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(ClientData.PubSub, "container")
  end

  ##########

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "container", message)
  end
end
