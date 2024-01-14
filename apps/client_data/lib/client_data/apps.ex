defmodule ClientData.Apps do
  @moduledoc """
  This module provides functionality for managing client applications.
  """

  alias Ecto.Changeset
  alias ClientData.Repo
  alias ClientData.Entities.App

  import Ecto.Query

  @err_unknown_provider "Request with an unknown provider"

  use Machinery,
    states: ["registered", "cloning", "cloning failed", "starting"],
    transitions: %{
      "registered" => "cloning",
      "cloning" => ["cloning failed", "starting"]
    }

  def get_all() do
    Repo.all(from a in App, order_by: [desc: a.inserted_at])
  end

  def get_by_state(state) do
    Repo.all(from a in App, where: a.state == ^state)
  end

  def update(changeset) do
    case Repo.update(changeset) do
      {:ok, app} ->
        broadcast({:app_updated, app})
        {:ok, app}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Machinery uses this to save state changes in DB
  def persist(app, state, metadata \\ %{}) do
    changeset = app |> Changeset.change(%{state: state} |> Map.merge(metadata))

    case update(changeset) do
      {:ok, app} -> app
      {:error, reason} -> {:error, reason}
    end
  end

  def register("simplerun:gh?" <> request) do
    params =
      request
      |> String.split("&")
      |> Enum.map(&split_pair/1)
      |> Enum.into(%{})

    with {:ok, org} <- params |> get("o", "org"),
         {:ok, repo} <- params |> get("r", "repo") do
      name = "#{org}/#{repo}"
      url = "https://github.com/#{name}"

      app = %{
        url: url,
        org: org,
        repo: repo,
        name: name,
        provider: :github,
        dockerfile: Map.get(params, "f")
      }

      changeset = App.changeset(%App{}, app)

      case Repo.insert(changeset) do
        {:ok, app} ->
          broadcast({:app_registered, app})
          GenServer.cast(:repo_manager, {:clone, app})
          :ok

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def register(_), do: {:error, @err_unknown_provider}

  def subscribe() do
    Phoenix.PubSub.subscribe(ClientData.PubSub, "app")
  end

  ##########

  defp split_pair(pair) do
    kv = String.split(pair, "=")

    case length(kv) do
      2 -> {Enum.at(kv, 0), Enum.at(kv, 1)}
      _ -> {nil, nil}
    end
  end

  defp get(params, key, field) do
    val = Map.get(params, key, nil)

    case val do
      nil -> {:error, "Request with a missing #{field}"}
      _ -> {:ok, val}
    end
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "app", message)
  end
end
