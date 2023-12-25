defmodule Actions.Response do
  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]

  def to_json({:ok, data}, status_code, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(data))
  end

  def to_json({:error, reason}, status_code, conn) when is_binary(reason) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(%{error: reason}))
  end
end
