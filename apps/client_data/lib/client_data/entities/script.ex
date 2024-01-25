defmodule ClientData.Entities.Script do
  @moduledoc """
  This module represents the schema for the 'scripts' table in the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ClientData.Entities.App

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scripts" do
    field :name, :string
    field :file, :string
    field :order, :integer
    field :type, Ecto.Enum, values: [:pre, :post]
    field :errors, {:array, :string}, default: []

    field :state, Ecto.Enum,
      values: [:registered, :running, :failed, :success],
      default: :registered

    belongs_to :app, App

    timestamps()
  end

  @doc false
  def changeset(script, attrs) do
    script
    |> cast(attrs, [:name, :file, :order, :type, :errors, :state])
    |> validate_required([:name, :file, :order, :type, :state])
  end
end
