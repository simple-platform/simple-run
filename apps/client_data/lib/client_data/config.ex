defmodule ClientData.Config do
  @moduledoc """
  Module for managing simplerun configuration
  """

  alias ClientData.Apps

  @err_missing_compose_file "Missing 'compose_file' in simplerun config"

  def get(app) do
    with {:ok, path} <- Apps.get_path(app),
         {:ok, config} <- get_config(path),
         :ok <- validate_config(config) do
      {:ok, config}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  ##########

  defp get_config(path) do
    config_file = path |> Path.join("simple-run.yaml")

    if config_file |> File.exists?(),
      do: YamlElixir.read_from_file(config_file),
      else: {:error, "Can not find simple-run.yaml at the repo root"}
  end

  defp validate_config(%{"version" => "1.0.0"} = config) do
    with :ok <- config |> Map.get("prescripts", []) |> validate_scripts(:pre),
         :ok <- config |> Map.get("postscripts", []) |> validate_scripts(:post),
         compose_file <- config |> Map.get("compose_file", "") |> String.trim() do
      if compose_file != "", do: :ok, else: {:error, @err_missing_compose_file}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_config(_) do
    {:error, "Invalid or missing version in simplerun config"}
  end

  defp validate_scripts(scripts, type) do
    case scripts |> Enum.reduce({1, type, []}, &validate_script/2) do
      {_order, _type, []} -> :ok
      {_order, _type, errors} -> {:error, errors}
    end
  end

  defp validate_script(script, {order, type, errors}) do
    errors =
      with _name <- script |> Map.get("name", {:error, build_error("name", order, type)}),
           _file <- script |> Map.get("file", {:error, build_error("file", order, type)}) do
        errors
      else
        {:error, reason} -> [reason | errors]
      end

    {order + 1, type, errors}
  end

  defp build_error(key, order, type),
    do: "Missing '#{key}' for #{type} script at index #{order - 1}"
end
