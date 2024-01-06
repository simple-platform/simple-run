defmodule Client.Api.Container do
  @moduledoc """
  This module provides functions for interacting with the container manager.
  """

  def subscribe do
    Phoenix.PubSub.subscribe(Client.PubSub, "container")
  end
end
