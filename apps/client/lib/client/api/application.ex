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

  def register(request) do
    GenServer.call(@name, {:register, request})
  end

  def inc_run_number(app) do
    GenServer.call(@name, {:update, %App{app | run_number: (app.run_number || 0) + 1}})
  end

  def set_ports(app, ports) do
    GenServer.call(@name, {:update, %App{app | ports: ports}})
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

  def set_progress(app, progress) do
    GenServer.call(@name, {:update, %App{app | progress: progress}})
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Client.PubSub, "application")
  end
end
