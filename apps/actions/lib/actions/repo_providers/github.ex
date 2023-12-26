defmodule Actions.RepoProviders.GitHub do
  @moduledoc """
  Module for interacting with GitHub repositories.
  """

  alias Actions.HttpClient
  alias Actions.Behaviors.RepoProvider

  @behaviour RepoProvider

  @gh_token Application.compile_env(:actions, :github_token)
  @req Application.compile_env(:actions, :http_client, HttpClient)

  @err_invalid_repo_url "Invalid repository URL"

  @gql_repo_details """
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      description
      owner {
        avatarUrl
      }
      default_branch: defaultBranchRef {
        name
      }
    }
  }
  """

  @impl RepoProvider
  def get_details("https://" <> repo_path) do
    case get_repo_info(repo_path) do
      {:error, reason} -> {:error, reason}
      {:ok, repo_info} -> {:ok, repo_info}
    end
  end

  defp get_repo_info(repo_path) do
    with {:ok, {org, repo}} <- String.split(repo_path, "/") |> get_org_and_repo(),
         {:ok, %{:body => body}} <- query(@gql_repo_details, %{:owner => org, :name => repo}) do
      %{"data" => data, "errors" => errors} = body

      case length(errors) > 0 do
        false -> {:ok, data}
        true -> {:error, errors |> Enum.map(fn error -> error["message"] end)}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp query(graphql, variables) do
    req =
      @req.new(
        url: "https://api.github.com/graphql",
        headers: %{"Authorization" => "bearer #{@gh_token}"}
      )
      |> AbsintheClient.attach()

    {:ok, @req.post!(req, graphql: {graphql, variables})}
  end

  defp get_org_and_repo(["github.com", org_name, repo_name]), do: {:ok, {org_name, repo_name}}
  defp get_org_and_repo([_invalid]), do: {:error, @err_invalid_repo_url}
end
