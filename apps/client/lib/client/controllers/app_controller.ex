defmodule Client.AppController do
  use Client, :controller

  def register_app(conn, %{"request" => request}) do
    IO.puts("!!!")
    IO.puts(request)
    IO.puts("!!!")

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{ok: true}))
  end
end
