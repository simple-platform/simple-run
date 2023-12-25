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

  def get_details(conn, %{"provider" => provider, "url" => url})
      when provider in @supported_providers do
    the_provider = @providers[provider]

    case the_provider.get_details(url) do
      {:ok, details} ->
        {:ok, details} |> to_json(200, conn)

      {:error, :not_found} ->
        {:error, @err_not_found} |> to_json(404, conn)

      {:error, reason} ->
        {:error, reason} |> to_json(500, conn)
    end
  end

  def get_details(conn, %{"provider" => provider}) do
    {:error, "Unsupported provider: #{provider}"} |> to_json(422, conn)
  end
end
