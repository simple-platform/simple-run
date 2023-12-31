defmodule Actions.RepoController do
  use Actions, :controller
  import Actions.Response

  @github_provider Application.compile_env(
                     :actions,
                     :github_provider,
                     Actions.RepoProviders.GitHub
                   )

  @providers %{"github" => @github_provider}
  @supported_providers Map.keys(@providers)

  @err_not_found "Repository not found"

  def get_metadata(conn, %{"provider" => a_provider, "url" => url})
      when a_provider in @supported_providers do
    provider = @providers[a_provider]

    case provider.get_metadata(url) do
      {:ok, metadata} -> {:ok, metadata} |> to_json(200, conn)
      {:error, :not_found} -> {:error, @err_not_found} |> to_json(404, conn)
      {:error, reason} -> {:error, reason} |> to_json(500, conn)
    end
  end

  def get_metadata(conn, %{"provider" => provider}) do
    {:error, "Unsupported provider: #{provider}"} |> to_json(422, conn)
  end
end
