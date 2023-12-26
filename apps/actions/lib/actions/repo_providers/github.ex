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
      contents: object(expression: "HEAD:") {
        ... on Tree {
          entries {
            name
            type
          }
        }
      }
    }
  }
  """

  @impl RepoProvider
  def get_metadata("https://" <> path) do
    with {:ok, {org, repo}} <- path |> String.split("/") |> get_org_and_repo(),
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
      :iconUrl => metadata["owner"]["avatarUrl"],
      :dockerFiles => get_docker_files(metadata["contents"])
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

  defp get_docker_files(%{"entries" => entries}) do
    entries
    |> Enum.filter(fn entry ->
      name = String.downcase(entry["name"])
      entry["type"] == "blob" && String.contains?(name, "docker") && name != ".dockerignore"
    end)
    |> Enum.map(fn entry -> entry["name"] end)
  end

  defp get_docker_files(_), do: []

  defp get_org_and_repo(["github.com", org, repo]), do: {:ok, {org, repo}}
  defp get_org_and_repo(_invalid), do: {:error, @err_invalid_repo_url}
end
