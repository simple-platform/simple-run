defmodule ClientCore.Api.Applications do
  @moduledoc """
  This module provides functions for interacting with the application manager.
  """

  alias ClientCore.Entities.Application

  @name :application_manager

  def get_all do
    GenServer.call(@name, :get_all)
  end

  def register("simplerun:gh?" <> request) do
    request = request |> String.trim() |> String.downcase()

    case process_request(request, "github") do
      {:ok, app} ->
        GenServer.call(@name, {:add, app})
        broadcast({:app_registered, app})
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  def register(_) do
    {:error, "Invalid application registration request"}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(ClientCore.PubSub, "applications")
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientCore.PubSub, "applications", message)
  end

  defp process_request(request, provider) do
    parse_request(request)
    |> build_app(provider)
    |> generate_response()
  end

  defp parse_request(request) do
    request
    |> String.split("&")
    |> Enum.map(&String.split(&1, "="))
  end

  defp build_app(parsed_request, provider) do
    Enum.reduce_while(parsed_request, {:ok, %Application{provider: provider}}, fn [key, val],
                                                                                  {:ok, app} ->
      case update_app(key, val, app) do
        {:error, reason} -> {:halt, {:error, reason}}
        {:ok, updated_app} -> {:cont, {:ok, updated_app}}
      end
    end)
  end

  defp update_app("o", val, app), do: {:ok, %Application{app | org: val}}
  defp update_app("r", val, app), do: {:ok, %Application{app | repo: val}}
  defp update_app("f", val, app), do: {:ok, %Application{app | file_to_run: val}}
  defp update_app(_, _, _), do: {:error, "Invalid application registration request"}

  defp generate_response({:error, reason}), do: {:error, reason}
  defp generate_response({:ok, app}), do: {:ok, generate_app(app)}

  defp generate_app(%Application{org: org, repo: repo} = app) do
    url = "https://github.com/#{org}/#{repo}"

    %Application{
      app
      | id: UUID.uuid5(:url, url),
        name: "#{org}/#{repo}",
        url: url,
        created_at: DateTime.utc_now() |> DateTime.to_unix()
    }
  end
end
