defmodule Client.AppController do
  use Client, :controller

  import Client.Response

  def register_app(conn, %{"request" => request}) do
    # case Application.register(request) do
    #   :ok -> {:ok, true} |> to_json(201, conn)
    #   {:error, reason} -> {:error, reason} |> to_json(422, conn)
    # end
    {:ok, true} |> to_json(201, conn)
  end
end
