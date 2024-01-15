defmodule ClientData.Entities.Container do
  @moduledoc """
  This module represents the schema for the 'containers' table in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ClientData.Entities.App

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "containers" do
    field :name, :string
    field :progress, :string
    field :use_dockerfile, :boolean, default: false
    field :errors, {:array, :string}, default: []

    field :state, Ecto.Enum,
      values: [:scheduled, :building, :build_failed, :starting, :running, :run_failed, :stopped],
      default: :scheduled

    belongs_to :app, App

    timestamps()
  end

  @doc false
  def changeset(container, attrs) do
    container
    |> cast(attrs, [:name, :state, :progress, :use_dockerfile])
    |> validate_required([:name, :state, :use_dockerfile])
  end
end
