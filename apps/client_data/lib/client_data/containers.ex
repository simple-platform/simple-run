defmodule ClientData.Containers do
  @moduledoc """
  This module provides functionality for managing containers.
  """

  alias Ecto.Changeset

  alias ClientData.Repo
  alias ClientData.Entities.Container

  # use Machinery,
  #   states: ["scheduled", "building", "build failed", "running", "run failed", "stopped"],
  #   transitions: %{
  #     "scheduled" => "building",
  #     "building" => ["build failed", "running"],
  #     "running" => ["run failed", "stopped"]
  #   }

  def get_all() do
    Repo.all(Container)
  end

  def create(container) do
    changeset = Container.changeset(%Container{}, container)

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
