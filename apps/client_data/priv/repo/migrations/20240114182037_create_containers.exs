defmodule ClientData.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :state, :string, default: "scheduled"
      add :progress, :string
      add :use_dockerfile, :boolean, default: false
      add :app_id, references(:apps, type: :binary_id)

      timestamps()
    end
  end
end
