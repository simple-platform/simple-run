defmodule ClientData.Repo.Migrations.AddAppsTable do
  use Ecto.Migration

  def change do
    create table(:apps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :url, :string, null: false
      add :org, :string, null: false
      add :repo, :string, null: false
      add :name, :string, null: false
      add :state, :string, default: "registered"
      add :errors, {:array, :string}, default: []
      add :progress, :string
      add :provider, :string, default: "github", null: false
      add :dockerfile, :string

      timestamps()
    end

    create unique_index(:apps, [:url])
    create unique_index(:apps, [:provider, :org, :repo])
  end
end
