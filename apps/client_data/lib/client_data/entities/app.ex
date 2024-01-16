defmodule ClientData.Entities.App do
  @moduledoc """
  This module represents the schema for the 'apps' table in the database.
  """

  use Ecto.Schema

  alias ClientData.Entities.Container

  alias Ecto.Changeset
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "apps" do
    field :url, :string
    field :org, :string
    field :repo, :string
    field :name, :string
    field :errors, {:array, :string}, default: []
    field :progress, :string
    field :dockerfile, :string

    field :provider, Ecto.Enum, values: [:github], default: :github

    field :state, Ecto.Enum,
      values: [:registered, :cloning, :cloning_failed, :starting],
      default: :registered

    has_many :containers, Container

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:url, :org, :repo, :name, :state, :errors, :progress, :provider, :dockerfile])
    |> validate_required([:url, :org, :repo, :name, :state, :provider])
    |> cast_id()
    |> unique_constraint(:url)
    |> unique_constraint([:provider, :org, :repo])
  end

  ##########

  defp cast_id(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{url: url}} ->
        changeset |> put_change(:id, UUID.uuid5(:url, url))

      _ ->
        changeset
    end
  end
end
