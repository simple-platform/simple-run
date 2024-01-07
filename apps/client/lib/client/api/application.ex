defmodule Client.Api.Application do
  @moduledoc """
  This module provides functions for interacting with the application manager.
  """

  alias Client.Entities.Application, as: App

  @name :application_manager

  def get_all do
    GenServer.call(@name, {:get, :all})
  end

  def get_with_state(state) do
    GenServer.call(@name, {:get, state})
  end

  def schedule_execution(app) do
    set_state(app, :scheduled)
  end

  def register(request) do
    GenServer.call(@name, {:register, request})
  end

  def set_state(app, state) do
    GenServer.call(@name, {:update, %App{app | state: state, errors: []}})
  end

  def set_state(app, state, error) when is_binary(error) do
    GenServer.call(@name, {:update, %App{app | state: state, errors: [error]}})
  end

  def set_state(app, state, errors) when is_list(errors) do
    GenServer.call(@name, {:update, %App{app | state: state, errors: errors}})
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Client.PubSub, "application")
  end
end
