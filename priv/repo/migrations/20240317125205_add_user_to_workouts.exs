defmodule BodyArchitect.Repo.Migrations.AddUserToWorkouts do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
