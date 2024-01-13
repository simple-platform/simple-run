defmodule Client.Utils.Docker do
  @moduledoc """
  Module for interacting with Docker.
  """

  def get_status() do
    try do
      _ = ~w(docker ps) |> Exile.stream!() |> Enum.into("")

      {true, true}
    rescue
      _ in Exile.Stream.AbnormalExit -> {true, false}
      _ -> {false, false}
    end
  end

  def start() do
    try do
      _ = ~w(open /Applications/Docker.app) |> Exile.stream!() |> Enum.into("")
    rescue
      _ -> :ok
    end
  end

  ##########
end
