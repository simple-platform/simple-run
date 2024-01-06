defmodule Client.Utils.Docker do
  @moduledoc """
  Module for managing Docker-related utilities.
  """

  def get_status() do
    try do
      {get_version(), is_running()}
    rescue
      _ -> {nil, false}
    end
  end

  defp get_version() do
    Exile.stream(["docker", "-v"], stderr: :consume)
    |> Enum.reduce(nil, fn
      {:exit, {:status, 0}}, version -> version
      {:exit, {:status, _}}, _version -> nil
      {_, version}, _version -> version
    end)
  end

  defp is_running() do
    Exile.stream(["docker", "ps"], stderr: :consume)
    |> Enum.reduce(false, fn
      {:exit, {:status, 0}}, _running -> true
      _, _running -> false
    end)
  end
end
