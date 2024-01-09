defmodule Client.Managers.Helpers do
  @moduledoc """
  Module for providing helper functions for managers.
  """

  alias Client.Entities.Application, as: App

  def get_active(db, state) do
    min_key = {:active, state, {}}
    max_key = {:active, state, {nil, nil}}

    db
    |> CubDB.select(min_key: min_key, max_key: max_key)
    |> Stream.map(fn {{:active, _state, {id}}, _value} -> id end)
  end

  def chunk_by_category(apps) do
    apps
    |> Enum.reduce({[], [], []}, fn %App{file_to_run: file_to_run} = app,
                                    {docker, compose, simplerun} ->
      case get_category(file_to_run) do
        :docker -> {[app | docker], compose, simplerun}
        :compose -> {docker, [app | compose], simplerun}
        :simplerun -> {docker, compose, [app | simplerun]}
      end
    end)
  end

  defp get_category(nil), do: :simplerun

  defp get_category(file) do
    if String.ends_with?(file, ".yml") or String.ends_with?(file, ".yaml"),
      do: :compose,
      else: :docker
  end
end
