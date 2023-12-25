defmodule Actions.RepoProviders.GitHub do
  @moduledoc """
  Module for interacting with GitHub repositories.
  """

  alias Actions.Behaviors.RepoProvider

  @behaviour RepoProvider

  @impl RepoProvider
  def get_details(url) do
  end
end
