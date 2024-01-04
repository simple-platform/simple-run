defmodule ClientCore.Entities.Application do
  @moduledoc """
  This module represents the application entity and its attributes.
  """
  defstruct [
    :id,
    :provider,
    :org,
    :repo,
    :name,
    :url,
    :image_url,
    :clone_url,
    :file_to_run,
    :state,
    :created_at,
    :updated_at
  ]
end

defmodule ClientCore.Managers.Application do
  @moduledoc """
  This module manages the application data and provides functions for interacting with the application manager.
  """

  use GenServer
  alias ClientCore.Entities.Application, as: App

  @name :application_manager

  @min_key {:apps, "00000000-0000-0000-0000-000000000000"}
  @max_key {:apps, "ffffffff-ffff-ffff-ffff-ffffffffffff"}

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    {:ok, db}
  end

  def handle_call(:get_all, _from, db) do
    apps =
      CubDB.select(db, min_key: @min_key, max_key: @max_key)
      |> Stream.map(fn {_key, value} -> value end)

    {:reply, {:ok, apps}, db}
  end

  def handle_call({:add, %App{id: id} = app}, _from, db) do
    CubDB.put(db, {:apps, id}, app)
    {:reply, :ok, db}
  end
end
