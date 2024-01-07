defmodule Client.Managers.Repository do
  @moduledoc """
  This module manages interactions with repositories.
  """
  use GenServer

  alias Client.Utils.Git
  alias Client.Api.Application
  alias Client.Entities.Application, as: App

  @name :repository_manager

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    clone_repos(db)

    {:ok, db}
  end

  def handle_info(:clone, db) do
    clone_repos(db)

    {:noreply, db}
  end

  ##########

  defp clone_repos(db) do
    active_clones = get_active_clones(db) |> Enum.to_list()

    {:ok, apps} = Application.get_with_state(:cloning)

    _ =
      apps
      |> Stream.filter(fn %App{id: id} -> id not in active_clones end)
      |> Enum.to_list()
      |> Enum.map(fn app -> Task.start(fn -> db |> clone(app) end) end)

    self() |> Process.send_after(:clone, :timer.seconds(1))
  end

  defp get_active_clones(db) do
    min_key = {:active, :clone, {}}
    max_key = {:active, :clone, {nil, nil}}

    db
    |> CubDB.select(min_key: min_key, max_key: max_key)
    |> Stream.map(fn {{:active, :clone, {id}}, _value} -> id end)
  end

  def clone(db, %App{id: id, url: url, path: path} = app) do
    key = {:active, :clone, {id}}

    db |> CubDB.put(key, true)

    case Git.clone(url, path) do
      {:ok, stream} -> stream |> monitor_cloning(app)
      {:error, reason} -> app |> Application.set_state(:cloning_failed, reason)
    end

    db |> CubDB.delete(key)
  end

  defp monitor_cloning(stream, app) do
    Enum.reduce(stream, [], fn output, errors ->
      case output do
        {:stderr, line} ->
          [line | errors]

        {:exit, {:status, 0}} ->
          app |> Application.set_state(:scheduled)
          []

        {:exit, {:status, _nonzero}} ->
          app |> Application.set_state(:cloning_failed, errors |> Enum.reverse())
          []
      end
    end)
  end
end
