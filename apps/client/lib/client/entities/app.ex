defmodule Client.Entities.App do
  @moduledoc """
  Module for managing applications.
  """

  # @db GenServer.whereis(:db)

  @err_unknown_provider "Request with an unknown provider"

  defstruct [
    :id,
    :url,
    :org,
    :repo,
    :name,
    :state,
    :progress,
    :provider,
    :dockerfile,
    errors: [],
    containers: []
  ]

  def new("simplerun:gh?" <> request) do
    params =
      request
      |> String.split("&")
      |> Enum.map(&split_pair/1)
      |> Enum.into(%{})

    with {:ok, org} <- params |> get("o", "org"),
         {:ok, repo} <- params |> get("r", "repo") do
      name = "#{org}/#{repo}"
      url = "https://github.com/#{name}"

      app = %__MODULE__{
        id: UUID.uuid5(:url, url),
        url: url,
        org: org,
        repo: repo,
        name: name,
        provider: :github,
        dockerfile: Map.get(params, "f")
      }

      {:ok, app}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def new(_), do: {:error, @err_unknown_provider}

  def register(%__MODULE__{id: id} = app) do
    db() |> CubDB.put({:app, {id}}, app)
  end

  def get_all() do
    db()
    |> CubDB.select(min_key: {:app, {}}, max_key: {:app, {nil}, {nil}})
    |> Stream.map(fn {_key, val} -> val end)
  end

  ##########

  defp db, do: GenServer.whereis(:db)

  defp split_pair(pair) do
    kv = String.split(pair, "=")

    case length(kv) do
      2 -> {Enum.at(kv, 0), Enum.at(kv, 1)}
      _ -> {nil, nil}
    end
  end

  defp get(params, key, field) do
    val = Map.get(params, key, nil)

    case val do
      nil -> {:error, "Request with a missing #{field}"}
      _ -> {:ok, val}
    end
  end
end
