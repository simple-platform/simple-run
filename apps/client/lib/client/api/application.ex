defmodule Client.Api.Application do
  @moduledoc """
  This module provides functions for interacting with the application manager.
  """

  alias Client.Entities.Application, as: App

  @name :application_manager

  def get_all do
    GenServer.call(@name, :get_all)
  end

  def start(app) do
    set_state(app, :scheduled)
  end

  def register(request) do
    GenServer.call(@name, {:register, request})
  end

  def set_state(app, state) do
    GenServer.call(@name, {:update, %App{app | state: state, error: nil}})
  end

  def set_state(app, state, error) do
    GenServer.call(@name, {:update, %App{app | state: state, error: error}})
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Client.PubSub, "application")
  end
end
