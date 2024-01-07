defmodule Client.Entities.Application do
  @moduledoc """
  This module represents the application entity and its attributes.
  """

  defstruct [
    :id,
    :org,
    :repo,
    :name,
    :url,
    :path,
    :state,
    :errors,
    :provider,
    :file_to_run,
    :created_at,
    :updated_at
  ]
end

defmodule Client.Managers.Application do
  @moduledoc """
  This module manages the application data and provides functions for interacting with the application manager.
  """

  use GenServer

  alias Client.Entities.Application, as: App

  @name :application_manager

  @min_key {:app, {}}
  @max_key {:app, {nil, nil}}

  @err_invalid_reg_req "Invalid application registration request"

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    {:ok, db}
  end

  def handle_call({:get, :all}, _from, db) do
    {:reply, {:ok, get_apps(db)}, db}
  end

  def handle_call({:get, state}, _from, db) do
    apps =
      db
      |> get_apps()
      |> Stream.filter(fn %App{state: s} -> s == state end)

    {:reply, {:ok, apps}, db}
  end

  def handle_call({:register, "simplerun:" <> request}, _from, db) do
    request = request |> String.trim()

    with {provider, req} <- process_request(request),
         {:ok, kvp} <- parse_request(req),
         {:ok, app} <- build_app(provider, kvp),
         {:ok, url} <- get_repo_url(app),
         {:ok, app} <- enrich_app(%App{app | url: url}) do
      db |> CubDB.put({:app, {app.id}}, app)

      broadcast({:app_registered, app})

      {:reply, :ok, db}
    else
      {:error, reason} -> {:reply, {:error, reason}, db}
    end
  end

  def handle_call({:register, _request}, _from, db) do
    {:reply, {:error, @err_invalid_reg_req}, db}
  end

  def handle_call({:update, app}, _from, db) do
    {:reply, {:ok, db |> update_app(app)}, db}
  end

  ##########

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(Client.PubSub, "application", message)
  end

  defp get_apps(db) do
    db
    |> CubDB.select(min_key: @min_key, max_key: @max_key)
    |> Stream.map(fn {_key, value} -> value end)
  end

  defp update_app(db, %App{id: id} = app) do
    app = %App{app | updated_at: now()}

    db |> CubDB.put({:app, {id}}, app)
    broadcast({:app_updated, app})

    app
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
    init_app = %App{provider: provider, state: :cloning, errors: []}

    kvp
    |> Enum.reduce_while({:ok, init_app}, fn [key, val], {:ok, app} ->
      case set_value(key, val, app) do
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
             created_at: now()
         }}
    end
  end

  defp get_repo_root(:github), do: {:ok, "github.com"}
  defp get_repo_root(provider), do: {:error, "#{@err_invalid_reg_req}: #{provider}"}

  defp get_repo_url(%App{org: org, repo: repo, provider: provider}) when provider == :github,
    do: {:ok, "https://github.com/#{org}/#{repo}"}

  defp get_repo_url(%App{provider: provider}),
    do: {:error, "#{@err_invalid_reg_req}: #{provider}"}

  defp set_value("o", val, app), do: {:ok, %App{app | org: val}}
  defp set_value("r", val, app), do: {:ok, %App{app | repo: val}}
  defp set_value("f", val, app), do: {:ok, %App{app | file_to_run: val}}
  defp set_value(_, _, _), do: {:error, @err_invalid_reg_req}

  defp process_request("gh?" <> request), do: {:github, request}
  defp process_request(_), do: {:error, @err_invalid_reg_req}

  defp now(), do: DateTime.utc_now() |> DateTime.to_unix()
end
