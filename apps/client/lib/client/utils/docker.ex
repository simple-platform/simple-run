defmodule Client.Utils.Docker do
  @moduledoc """
  Module for interacting with Docker.
  """

  def get_status() do
    try do
      ~w(docker ps) |> Exile.stream!()

      {true, true}
    rescue
      _ in Exile.Stream.AbnormalExit -> {true, false}
      _ -> {false, false}
    end
  end

  def start() do
    try do
      ~w(open /Applications/Docker.app) |> Exile.stream!()
    rescue
      _ -> :ok
    end
  end

  ##########
end
