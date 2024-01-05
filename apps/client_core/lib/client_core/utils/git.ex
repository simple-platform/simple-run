defmodule ClientCore.Utils.Git do
  @moduledoc """
  Module for Git utility functions.
  """

  alias Porcelain.Result

  def clone(url, path) do
    case File.mkdir_p(path) do
      {:error, reason} ->
        {:error, "Unable to clone repository: #{reason}"}

      :ok ->
        %Result{out: output, status: status} =
          Porcelain.shell("git clone #{url} #{path}", err: :out)

        case status do
          0 -> :ok
          _ -> {:error, output}
        end
    end
  end
end
