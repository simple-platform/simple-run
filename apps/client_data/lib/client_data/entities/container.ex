defmodule ClientData.Entities.Container do
  @moduledoc """
  This module represents the schema for the 'containers' table in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ClientData.Entities.App

  schema "containers" do
    field :name, :string
    field :state, :string, default: "scheduled"
    field :progress, :string
    field :use_dockerfile, :boolean, default: false

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
