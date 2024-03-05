defmodule BodyArchitect.Repo.Migrations.AddTypeToWorkouts do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      add :type, :string
    end
  end
end
