defmodule Actions.RepoController do
  use Actions, :controller

  def get_details(conn, %{"provider" => "github", "url" => url}) do
  end
end
