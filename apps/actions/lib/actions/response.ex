defmodule Actions.Response do
  @moduledoc """
  This module provides functions to handle HTTP responses.
  It includes functions to convert data to JSON format and send the response.
  It also handles error responses, converting the error reason to JSON format.
  """

  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]

  def to_json({:ok, data}, status_code, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(data))
  end

  def to_json({:error, reason}, status_code, conn) when is_binary(reason) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(%{errors: [reason]}))
  end

  def to_json({:error, errors}, status_code, conn) when is_list(errors) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(%{errors: errors}))
  end
end
