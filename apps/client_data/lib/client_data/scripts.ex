defmodule ClientData.Scripts do
  @moduledoc """
  Module for managing client scripts
  """

  alias Ecto.Changeset

  alias ClientData.Repo
  alias ClientData.StateMachine
  alias ClientData.Entities.Script

  import Ecto.Query

  use StateMachine,
    states: [:registered, :running, :failed, :success],
    transitions: %{
      registered: [:running],
      running: [:failed, :success]
    }

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

  def run(app, type) do
    scripts =
      Repo.all(
        from s in Script,
          where: s.app_id == ^app.id and s.type == ^type,
          order_by: s.order
      )

    GenServer.call(:script_manager, {:run, app, scripts})
  end

  def update(changeset) do
    case Repo.update(changeset) do
      {:ok, script} ->
        broadcast({:script_updated, script})
        {:ok, script}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def persist_state_change(script, next_state, metadata) do
    changeset = script |> Changeset.change(%{state: next_state} |> Map.merge(metadata))
    update(changeset)
  end

  def pre_transition(app, _next_state, _metadata) do
    {:ok, app}
  end

  def post_transition(_app, _state, _metadata) do
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
      with script <- %{name: script["name"], file: script["file"], order: order, type: type},
           changeset <- app |> Ecto.build_assoc(:scripts, script),
           {:ok, script} <- Repo.insert(changeset) do
        broadcast({:script_registered, script})
        errors
      else
        {:error, reason} -> [reason | errors]
      end

    {errors, order + 1, app, type}
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(ClientData.PubSub, "script", message)
  end
end
