defmodule Client.Utils.Git do
  @moduledoc """
  Provides utility functions for interacting with Git.
  """

  def clone(url, path) do
    case File.mkdir_p(path) do
      :ok -> {:ok, ~w(git clone --progress #{url} #{path}) |> Exile.stream(stderr: :consume)}
      {:error, reason} -> {:error, "Unable to clone repository: #{reason}"}
    end
  end
end
