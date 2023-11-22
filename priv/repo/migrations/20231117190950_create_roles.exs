defmodule Yaocg.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all)
      add :actions, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:user_id])
  end
end
