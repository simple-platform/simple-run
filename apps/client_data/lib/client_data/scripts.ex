defmodule ClientData.Scripts do
  @moduledoc """
  Module for managing client scripts
  """

  alias ClientData.Repo
  alias ClientData.Entities.Script

  def get_all() do
    Repo.all(Script)
  end

  def create(app, config) do
    prescripts = config |> Map.get("prescripts", [])
    postscripts = config |> Map.get("postscripts", [])

    with :ok <- create_scripts(app, prescripts, :pre),
         :ok <- create_scripts(app, postscripts, :post) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(ClientData.PubSub, "script")
  end

  ##########

  defp create_scripts(app, scripts, type) do
    {errors, _order, _app, _type} = scripts |> Enum.reduce({[], 1, app, type}, &create_script/2)

    if errors == [], do: :ok, else: {:error, errors}
  end

  defp create_script(script, {errors, order, app, type}) do
    errors =
      with name <- script |> Map.get("name", {:error, build_error("name", order, type)}),
           file <- script |> Map.get("file", {:error, build_error("file", order, type)}),
           script <- %{name: name, file: file, order: order, type: type},
           changeset <- app |> Ecto.build_assoc(:scripts, script),
           {:ok, script} <- Repo.insert(changeset) do
        broadcast({:script_registered, script})
        errors
      else
        {:error, reason} -> [reason | errors]
      end

    {errors, order + 1, app, type}
  end

  defp build_error(key, order, type),
    do: "Missing '#{key}' for #{type} script at index #{order - 1}"

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "script", message)
  end
end
