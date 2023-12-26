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

  @gql_repo_metadata """
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      description
      owner {
        avatarUrl
      }
      defaultBranchRef {
        name
      }
    }
  }
  """

  @impl RepoProvider
  def get_metadata("https://" <> repo_path) do
    with {:ok, {org, repo}} <- String.split(repo_path, "/") |> get_org_and_repo(),
         {:ok, %{:body => body}} <- query(@gql_repo_metadata, %{:owner => org, :name => repo}) do
      errors = body |> Map.get("errors", [])

      case length(errors) > 0 do
        false -> {:ok, body["data"]["repository"] |> transform_metadata(org, repo)}
        true -> {:error, errors |> Enum.map(fn error -> error["message"] end)}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp transform_metadata(metadata, org, repo) do
    %{
      :org => org,
      :name => repo,
      :desc => metadata["description"],
      :default_branch => metadata["defaultBranchRef"]["name"],
      :icon_url => metadata["owner"]["avatarUrl"]
    }
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
