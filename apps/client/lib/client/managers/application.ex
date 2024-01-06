defmodule Client.Entities.Application do
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

defmodule Client.Managers.Application do
  @moduledoc """
  This module manages the application data and provides functions for interacting with the application manager.
  """

  use GenServer

  require Logger
  alias Client.Entities.Application, as: App
  alias Client.Utils.Docker

  @name :application_manager
  @repo_manager :repository_manager

  @min_key {:apps, "00000000-0000-0000-0000-000000000000"}
  @max_key {:apps, "ffffffff-ffff-ffff-ffff-ffffffffffff"}

  @err_invalid_reg_req "Invalid application registration request"

  def start_link(db) do
    GenServer.start_link(__MODULE__, db, name: @name)
  end

  def init(db) do
    process_scheduled_apps(db)

    {:ok, db}
  end

  def handle_call(:get_all, _from, db) do
    {:reply, {:ok, get_apps(db)}, db}
  end

  def handle_call({:register, "simplerun:" <> request}, _from, db) do
    request = request |> String.trim()

    with {provider, req} <- process_request(request),
         {:ok, kvp} <- parse_request(req),
         {:ok, app} <- build_app(provider, kvp),
         {:ok, url} <- get_repo_url(app),
         {:ok, app} <- enrich_app(%App{app | url: url}) do
      db |> CubDB.put({:apps, app.id}, app)

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

  def handle_call({:update, app}, _from, db) do
    {:reply, {:ok, update_app_in_db(db, app)}, db}
  end

  def handle_info({:update, app}, db) do
    update_app_in_db(db, app)
    {:noreply, db}
  end

  def handle_info(:process_scheduled_apps, db) do
    process_scheduled_apps(db)
    {:noreply, db}
  end

  def handle_info({:start_scheduled, %App{id: id} = app}, db) do
    scheduled_app_id = {:scheduled_app, id}
    scheduled_app = db |> CubDB.get(scheduled_app_id)

    case is_nil(scheduled_app) do
      false ->
        Logger.info("#{app.name}: is already scheduled, skipping")
        nil

      true ->
        db |> CubDB.put(scheduled_app_id, now())
        start_scheduled_app(app)
    end

    {:noreply, db}
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

  defp process_scheduled_apps(db) do
    pid = self()

    db
    |> get_apps()
    |> Stream.filter(fn %App{state: state} -> state == :scheduled end)
    |> Enum.each(fn app -> pid |> Process.send({:start_scheduled, app}, []) end)

    pid |> Process.send_after(:process_scheduled_apps, :timer.seconds(5))
  end

  defp start_scheduled_app(%App{file_to_run: file} = app) when not is_nil(file) do
    case Docker.dockerfile?(file) do
      true -> build_dockerfile(app)
      false -> run_docker_compose(app)
    end
  end

  defp start_scheduled_app(%App{file_to_run: file} = app) when is_nil(file) do
    IO.puts("!!! Starting #{app.name} with simple-run.yaml...")
  end

  defp build_dockerfile(app) do
    app = %App{app | state: :building, updated_at: now()}
    broadcast({:app_updated, app})

    pid = self()

    Docker.build_dockerfile(app)
    |> Enum.reduce(nil, fn output, error ->
      case output do
        {:stdout, line} ->
          IO.puts(line)
          error

        {:stderr, line} ->
          IO.puts(line)
          line

        {:exit, {:status, 0}} ->
          pid |> set_state(app, :starting)
          nil

        {:exit, {:status, _nonzero}} ->
          pid |> set_state(app, :build_failed, error)
          nil
      end
    end)
  end

  defp run_docker_compose(%App{file_to_run: file} = app) do
    IO.puts("Running docker-compose for: #{app.name} / #{file}")
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
    init_app = %App{provider: provider}

    kvp
    |> Enum.reduce_while({:ok, init_app}, fn [key, val], {:ok, app} ->
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
             created_at: now()
         }}
    end
  end

  defp set_state(pid, app, state) do
    pid |> Process.send({:update, %App{app | state: state, error: nil}}, [])
  end

  defp set_state(pid, app, state, error) do
    pid |> Process.send({:update, %App{app | state: state, error: error}}, [])
  end

  defp update_app_in_db(db, %App{id: id} = app) do
    app = %App{app | updated_at: now()}

    db |> CubDB.put({:apps, id}, app)
    broadcast({:app_updated, app})

    app
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

  defp now(), do: DateTime.utc_now() |> DateTime.to_unix()
end
