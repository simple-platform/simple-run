defmodule ClientData.Containers do
  @moduledoc """
  This module provides functionality for managing containers.
  """

  alias ClientData.Repo
  alias ClientData.Entities.Container

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

  def subscribe() do
    Phoenix.PubSub.subscribe(ClientData.PubSub, "container")
  end

  ##########

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "container", message)
  end
end
