defmodule Actions.RepoProviders.GitHubTest do
  use ExUnit.Case, async: true
  import Mox

  alias Actions.HttpClientMock
  alias Actions.RepoProviders.GitHub

  @api_url "https://api.github.com/graphql"
  @gh_token Application.compile_env(:actions, :github_token)
  @req_headers %{"authorization" => "bearer #{@gh_token}"}

  @valid_repo_url "https://github.com/simple-platform/simple-run"
  @invalid_repo_url "https://invalid-repo"
  @nonexistent_repo_url "https://github.com/simple-platform/nonexistent"

  @simple_run_config "version: 1.0.0\n\nprescripts:\n  - name: Environment Setup\n    file: ./scripts/local-setup.sh\n\ncontainers:\n  - name: Local Development Environment\n    file: ./docker-compose.yaml\n\npostscripts:\n  - name: Open VSCode\n    file: ./scripts/open-browser.sh\n"

  @err_invalid_simplerun_config "Invalid Simple Run config"

  setup do
    HttpClientMock
    |> expect(:new, fn [url: @api_url, headers: @req_headers] ->
      %Req.Request{}
    end)

    :ok
  end

  describe "get_metadata/1" do
    test "responds with error for invalid repos" do
      assert GitHub.get_metadata(@invalid_repo_url) == {:error, "Invalid repository URL"}
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

      assert GitHub.get_metadata(@nonexistent_repo_url) == {:error, [error_msg]}
    end

    test "responds with repo metadata on success" do
      resp = %{
        :body => %{
          "data" => %{
            "repository" => %{
              "description" => "Run containerized applications easily on your local machine.",
              "owner" => %{
                "avatarUrl" => "https://avatars.githubusercontent.com/u/121924292?s=48&v=4"
              },
              "contents" => %{
                "entries" => [
                  %{"name" => ".dockerignore", "type" => "blob"},
                  %{"name" => ".github", "type" => "tree"},
                  %{"name" => ".gitignore", "type" => "blob"},
                  %{"name" => "apps", "type" => "tree"},
                  %{"name" => "docker-compose.yaml", "type" => "blob"},
                  %{"name" => "Dockerfile", "type" => "blob"},
                  %{"name" => "package.json", "type" => "blob"},
                  %{"name" => "packages", "type" => "tree"}
                ]
              },
              "simplerun" => nil
            }
          }
        }
      }

      data = resp.body["data"]["repository"]

      expected = %{
        :org => "simple-platform",
        :name => "simple-run",
        :desc => data["description"],
        :iconUrl => data["owner"]["avatarUrl"],
        :dockerFiles => ["Dockerfile"],
        :simplerun => nil
      }

      HttpClientMock |> expect(:post!, fn _req, _params -> resp end)

      assert GitHub.get_metadata(@valid_repo_url) == {:ok, expected}
    end

    test "responds with simple-run config when simple-run.yaml is defined" do
      resp = %{
        :body => %{
          "data" => %{
            "repository" => %{
              "description" => "Run containerized applications easily on your local machine.",
              "owner" => %{
                "avatarUrl" => "https://avatars.githubusercontent.com/u/121924292?s=48&v=4"
              },
              "contents" => %{
                "entries" => [
                  %{"name" => ".dockerignore", "type" => "blob"},
                  %{"name" => ".github", "type" => "tree"},
                  %{"name" => ".gitignore", "type" => "blob"},
                  %{"name" => "apps", "type" => "tree"},
                  %{"name" => "docker-compose.yaml", "type" => "blob"},
                  %{"name" => "Dockerfile", "type" => "blob"},
                  %{"name" => "package.json", "type" => "blob"},
                  %{"name" => "packages", "type" => "tree"},
                  %{"name" => "simple-run.yaml", "type" => "blob"}
                ]
              },
              "simplerun" => %{
                "text" => @simple_run_config
              }
            }
          }
        }
      }

      data = resp.body["data"]["repository"]

      expected = %{
        :org => "simple-platform",
        :name => "simple-run",
        :desc => data["description"],
        :iconUrl => data["owner"]["avatarUrl"],
        :dockerFiles => ["Dockerfile"],
        :simplerun => %{
          :config => %{
            "version" => "1.0.0",
            "prescripts" => [
              %{"name" => "Environment Setup", "file" => "./scripts/local-setup.sh"}
            ],
            "containers" => [
              %{"name" => "Local Development Environment", "file" => "./docker-compose.yaml"}
            ],
            "postscripts" => [%{"name" => "Open VSCode", "file" => "./scripts/open-browser.sh"}]
          }
        }
      }

      HttpClientMock |> expect(:post!, fn _req, _params -> resp end)

      assert GitHub.get_metadata(@valid_repo_url) == {:ok, expected}
    end

    test "includes error when simple-run config is invalid" do
      resp = %{
        :body => %{
          "data" => %{
            "repository" => %{
              "description" => "Run containerized applications easily on your local machine.",
              "owner" => %{
                "avatarUrl" => "https://avatars.githubusercontent.com/u/121924292?s=48&v=4"
              },
              "contents" => %{
                "entries" => [
                  %{"name" => ".dockerignore", "type" => "blob"},
                  %{"name" => ".github", "type" => "tree"},
                  %{"name" => ".gitignore", "type" => "blob"},
                  %{"name" => "apps", "type" => "tree"},
                  %{"name" => "docker-compose.yaml", "type" => "blob"},
                  %{"name" => "Dockerfile", "type" => "blob"},
                  %{"name" => "package.json", "type" => "blob"},
                  %{"name" => "packages", "type" => "tree"},
                  %{"name" => "simple-run.yaml", "type" => "blob"}
                ]
              },
              "simplerun" => %{
                "text" => "version: 1\n\n:-=^!"
              }
            }
          }
        }
      }

      data = resp.body["data"]["repository"]

      expected = %{
        :org => "simple-platform",
        :name => "simple-run",
        :desc => data["description"],
        :iconUrl => data["owner"]["avatarUrl"],
        :dockerFiles => ["Dockerfile"],
        :simplerun => %{
          :error => @err_invalid_simplerun_config
        }
      }

      HttpClientMock |> expect(:post!, fn _req, _params -> resp end)

      assert GitHub.get_metadata(@valid_repo_url) == {:ok, expected}
    end
  end
end
