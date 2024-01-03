defmodule Client.HealthCheckController do
  use Client, :controller
  import Client.Response

  def get_status(conn, _params) do
    {:ok, true} |> to_json(200, conn)
  end
end
