defmodule Client.AppController do
  use Client, :controller

  import Client.Response
  alias Client.Api.Application

  def register_app(conn, %{"request" => request}) do
    case Application.register(request) do
      :ok -> {:ok, true} |> to_json(201, conn)
      {:error, reason} -> {:error, reason} |> to_json(422, conn)
    end
  end
end
