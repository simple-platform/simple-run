defmodule Actions.RepoProviders.GitHubTest do
  use ExUnit.Case, async: true
  import Mox

  alias Actions.HttpClientMock
  alias Actions.RepoProviders.GitHub

  @api_url "https://api.github.com/graphql"
  @gh_token Application.compile_env(:actions, :github_token)
  @req_headers %{"Authorization" => "bearer #{@gh_token}"}

  @invalid_repo_url "https://invalid-repo"
  @nonexistent_repo_url "https://github.com/simple-platform/nonexistent"

  setup do
    HttpClientMock
    |> expect(:new, fn [url: @api_url, headers: @req_headers] ->
      %Req.Request{}
    end)

    :ok
  end

  describe "get_details/1" do
    test "responds with error for invalid repos" do
      assert GitHub.get_details(@invalid_repo_url) == {:error, "Invalid repository URL"}
    end

    test "responds with error for github errors" do
      error_msg = "error from github"

      resp = %{
        :body => %{
          "data" => %{},
          "errors" => [%{"message" => error_msg}]
        }
      }

      HttpClientMock |> expect(:post!, fn _req, _params -> resp end)

      assert GitHub.get_details(@nonexistent_repo_url) == {:error, [error_msg]}
    end
  end
end
