defmodule ClientCore.Entities.Application do
  @moduledoc """
  This module represents the application entity and its attributes.
  """
  defstruct [
    :id,
    :provider,
    :org,
    :repo,
    :name,
    :url,
    :path,
    :state,
    :error,
    :file_to_run,
    :created_at,
    :updated_at
  ]
end

defmodule ClientCore.Managers.Application do
  @moduledoc """
  This module manages the application data and provides functions for interacting with the application manager.
  """

  use GenServer
  alias ClientCore.Entities.Application, as: App

  @name :application_manager
  @repo_manager :repository_manager

  @min_key {:apps, "00000000-0000-0000-0000-000000000000"}
  @max_key {:apps, "ffffffff-ffff-ffff-ffff-ffffffffffff"}

  @err_invalid_reg_req "Invalid application registration request"

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    {:ok, db}
  end

  def handle_call(:get_all, _from, db) do
    apps =
      CubDB.select(db, min_key: @min_key, max_key: @max_key)
      |> Stream.map(fn {_key, value} -> value end)

    {:reply, {:ok, apps}, db}
  end

  def handle_call({:register, "simplerun:" <> request}, _from, db) do
    request = request |> String.trim() |> String.downcase()

    with {provider, req} <- process_request(request),
         {:ok, kvp} <- parse_request(req),
         {:ok, app} <- build_app(provider, kvp),
         {:ok, url} <- get_repo_url(app),
         {:ok, app} <- enrich_app(%App{app | url: url}) do
      CubDB.put(db, {:apps, app.id}, app)

      broadcast({:app_registered, app})
      GenServer.cast(@repo_manager, {:clone, app})

      {:reply, :ok, db}
    else
      {:error, reason} -> {:reply, {:error, reason}, db}
    end
  end

  def handle_call({:register, _request}, _from, db) do
    {:reply, {:error, @err_invalid_reg_req}, db}
  end

  def handle_call({:update, %App{id: id} = app}, _from, db) do
    app = %App{app | updated_at: DateTime.utc_now() |> DateTime.to_unix()}

    CubDB.put(db, {:apps, id}, app)
    broadcast({:app_updated, app})

    {:reply, {:ok, app}, db}
  end

  def handle_cast({:start, app}, db) do
    IO.puts("!!! Starting application #{app.name}...")
    {:noreply, db}
  end

  ##########

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientCore.PubSub, "applications", message)
  end

  defp parse_request(request) do
    case request |> String.split("&") |> get_kvp_list() do
      {:ok, list} -> {:ok, list}
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_kvp_list(parts) do
    parts
    |> Enum.reduce_while({:ok, []}, fn part, {:ok, list} ->
      kvp = part |> String.split("=")

      if length(kvp) == 2 do
        {:cont, {:ok, [kvp | list]}}
      else
        {:halt, {:error, @err_invalid_reg_req}}
      end
    end)
  end

  defp build_app(provider, kvp) when provider == :github do
    kvp
    |> Enum.reduce_while({:ok, %App{provider: provider}}, fn [key, val], {:ok, app} ->
      case update_app(key, val, app) do
        {:error, reason} -> {:halt, {:error, reason}}
        {:ok, updated_app} -> {:cont, {:ok, updated_app}}
      end
    end)
  end

  defp build_app(provider, _kvp), do: {:error, "#{@err_invalid_reg_req}: #{provider}"}

  defp enrich_app(%App{org: org, repo: repo, url: url} = app) do
    case get_repo_root(app.provider) do
      {:error, reason} ->
        {:error, reason}

      {:ok, repo_root} ->
        {:ok,
         %App{
           app
           | id: UUID.uuid5(:url, url),
             name: "#{org}/#{repo}",
             path: System.user_home!() |> Path.join("simplerun/#{repo_root}/#{org}/#{repo}"),
             created_at: DateTime.utc_now() |> DateTime.to_unix()
         }}
    end
  end

  defp get_repo_root(:github), do: {:ok, "github.com"}
  defp get_repo_root(provider), do: {:error, "#{@err_invalid_reg_req}: #{provider}"}

  defp get_repo_url(%App{org: org, repo: repo, provider: provider}) when provider == :github,
    do: {:ok, "https://github.com/#{org}/#{repo}"}

  defp get_repo_url(%App{provider: provider}),
    do: {:error, "#{@err_invalid_reg_req}: #{provider}"}

  defp update_app("o", val, app), do: {:ok, %App{app | org: val}}
  defp update_app("r", val, app), do: {:ok, %App{app | repo: val}}
  defp update_app("f", val, app), do: {:ok, %App{app | file_to_run: val}}
  defp update_app(_, _, _), do: {:error, @err_invalid_reg_req}

  defp process_request("gh?" <> request), do: {:github, request}
  defp process_request(_), do: {:error, @err_invalid_reg_req}
end
