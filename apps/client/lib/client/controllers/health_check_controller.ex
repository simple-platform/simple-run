defmodule Client.HealthCheckController do
  use Client, :controller

  def get_status(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{ok: true}))
  end
end
