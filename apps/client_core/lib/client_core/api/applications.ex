defmodule ClientCore.Api.Applications do
  @moduledoc """
  This module provides functions for interacting with the application manager.
  """

  @name :application_manager

  def get_all do
    GenServer.call(@name, :get_all)
  end

  def register(request) do
    GenServer.call(@name, {:register, request})
  end

  def subscribe do
    Phoenix.PubSub.subscribe(ClientCore.PubSub, "applications")
  end
end
