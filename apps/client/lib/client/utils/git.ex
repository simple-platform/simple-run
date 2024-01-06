defmodule Client.Utils.Git do
  @moduledoc """
  Module for Git utility functions.
  """

  def clone(url, path) do
    case File.mkdir_p(path) do
      {:error, reason} -> {:error, "Unable to clone repository: #{reason}"}
      :ok -> {:ok, Exile.stream(["git", "clone", url, path], stderr: :consume)}
    end
  end
end
