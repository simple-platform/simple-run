defmodule ClientData.Repo do
  use Ecto.Repo,
    otp_app: :client_data,
    adapter: Ecto.Adapters.SQLite3
end
