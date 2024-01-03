defmodule ClientCore.Managers.Application do
  @moduledoc """
  This module manages the application data and provides functions for interacting with the application manager.
  """

  use GenServer

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
    apps = CubDB.select(db, min_key: @min_key, max_key: @max_key)
    {:reply, {:ok, apps}, db}
  end
end
