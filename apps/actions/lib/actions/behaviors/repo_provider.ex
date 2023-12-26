defmodule Actions.Behaviors.RepoProvider do
  @moduledoc """
  Provides behavior for fetching repository details.
  """

  @callback get_metadata(binary()) :: {:error, :not_found} | {:error, binary()} | {:ok, map()}
end
