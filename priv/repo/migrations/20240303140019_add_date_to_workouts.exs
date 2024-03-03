defmodule BodyArchitect.Repo.Migrations.AddDateToWorkouts do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      add :date, :date
    end
  end
end
