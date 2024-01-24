defmodule ClientData.Apps do
  @moduledoc """
  This module provides functionality for managing applications.
  """

  alias Ecto.Changeset

  alias ClientData.Entities.App
  alias ClientData.StateMachine
  alias ClientData.Containers
  alias ClientData.Scripts
  alias ClientData.Repo

  import Ecto.Query

  @err_unknown_provider "Request with an unknown provider"

  use StateMachine,
    states: [:registered, :cloning, :clone_failed, :starting, :start_failed],
    transitions: %{
      registered: [:cloning],
      cloning: [:clone_failed, :starting],
      starting: [:start_failed]
    }

  def get_all() do
    Repo.all(from a in App, order_by: [desc: a.inserted_at])
  end

  def get_by_id(id) do
    Repo.get(App, id)
  end

  def get_by_state(state) do
    Repo.all(from a in App, where: a.state == ^state)
  end

  def get_path(%App{name: name, provider: provider}) do
    case get_repo_root(provider) do
      {:ok, repo_root} ->
        {:ok, System.user_home!() |> Path.join("simplerun/#{repo_root}/#{name}")}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_short_path!(%App{name: name, provider: provider}) do
    case get_repo_root(provider) do
      {:ok, repo_root} -> "~/simplerun/#{repo_root}/#{name}"
      {:error, reason} -> raise reason
    end
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

  def persist_state_change(app, next_state, metadata) do
    changeset = app |> Changeset.change(%{state: next_state} |> Map.merge(metadata))
    update(changeset)
  end

  def pre_transition(app, _next_state, _metadata) do
    {:ok, app}
  end

  def post_transition(%App{dockerfile: dockerfile} = app, :starting, _metadata)
      when not is_nil(dockerfile) and dockerfile != "" do
    app |> Containers.create(%{name: "sr-#{app.org}-#{app.repo}", use_dockerfile: true})
  end

  def post_transition(%App{dockerfile: dockerfile} = app, :starting, _metadata)
      when is_nil(dockerfile) or dockerfile == "" do
    case get_path(app) do
      {:ok, path} ->
        config_file = path |> Path.join("simple-run.yaml")

        if config_file |> File.exists?() do
          with {:ok, config} <- YamlElixir.read_from_file(config_file),
               :ok <- app |> Scripts.create(config),
               :ok <- app |> Scripts.run(:pre) do
          else
            {:error, reason} -> app |> mark_start_failed(reason)
          end
        else
          app |> mark_start_failed("Can not find simple-run.yaml at the repo root")
        end

      {:error, reason} ->
        app |> mark_start_failed(reason)
    end
  end

  def post_transition(_app, _state, _metadata) do
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

  defp get_repo_root(:github), do: {:ok, "github.com"}
  defp get_repo_root(provider), do: {:error, "Unknown provider: #{provider}"}

  defp mark_start_failed(app, reason) do
    app |> StateMachine.transition_to(__MODULE__, :start_failed, %{errors: [reason]})
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "app", message)
  end
end
