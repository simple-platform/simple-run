defmodule Client.DashboardController do
  use Client, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
