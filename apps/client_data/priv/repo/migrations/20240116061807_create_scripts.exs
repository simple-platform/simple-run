defmodule ClientData.Repo.Migrations.CreateScripts do
  use Ecto.Migration

  def change do
    create table(:scripts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :file, :string, null: false
      add :order, :integer, null: false
      add :type, :string, null: false
      add :state, :string, default: "registered"
      add :errors, {:array, :string}, default: []
      add :app_id, references(:apps, type: :binary_id)

      timestamps()
    end

    create unique_index(:scripts, [:app_id, :type, :order])
  end
end
