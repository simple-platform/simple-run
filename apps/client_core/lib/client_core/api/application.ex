defmodule ClientCore.Api.Application do
  @moduledoc """
  This module provides functions for interacting with the application manager.
  """

  @name :application_manager

  def get_all do
    GenServer.call(@name, :get_all)
  end
end
