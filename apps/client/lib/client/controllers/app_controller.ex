defmodule Client.AppController do
  use Client, :controller

  import Client.Response
  alias Client.Entities.App

  def register_app(conn, %{"request" => request}) do
    with {:ok, app} <- App.new(request),
         :ok <- App.register(app) do
      {:ok, true} |> to_json(201, conn)
    else
      {:error, reason} -> {:error, reason} |> to_json(422, conn)
    end
  end
end
