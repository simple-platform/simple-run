defmodule Actions.RepoControllerTest do
  use Actions.ConnCase, async: true
  import Mox

  alias Actions.RepoProviderMock

  @gitlab_repo URI.encode_www_form("https://gitlab.com/simple-platform/simple-run")

  @github_repo URI.encode_www_form("https://github.com/simple-platform/simple-run")
  @github_nonexistent_repo URI.encode_www_form("https://github.com/simple-platform/nonexistent")

  describe "get_details/2" do
    test "responds with error for unsupported providers", %{conn: conn} do
      conn = get(conn, "/repo/gitlab/#{@gitlab_repo}")
      assert json_response(conn, 422) == %{"errors" => ["Unsupported provider: gitlab"]}
    end

    test "responds with error for nonexistent repos", %{conn: conn} do
      path = "/repo/github/#{@github_nonexistent_repo}"

      RepoProviderMock |> expect(:get_metadata, fn _path -> {:error, :not_found} end)

      conn = get(conn, path)
      assert json_response(conn, 404) == %{"errors" => ["Repository not found"]}
    end

    test "responds with error for internal errors", %{conn: conn} do
      error = "Internal error"
      path = "/repo/github/#{@github_repo}"

      RepoProviderMock |> expect(:get_metadata, fn _path -> {:error, [error]} end)

      conn = get(conn, path)
      assert json_response(conn, 500) == %{"errors" => [error]}
    end

    test "responds with details for supported provider when no internal errors", %{conn: conn} do
      details = %{}
      path = "/repo/github/#{@github_repo}"

      RepoProviderMock |> expect(:get_metadata, fn _path -> {:ok, details} end)

      conn = get(conn, path)
      assert json_response(conn, 200) == details
    end
  end
end
