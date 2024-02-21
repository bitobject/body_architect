defmodule BodyArchitect.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :reps, :integer
      add :weight, :float
      add :workout_id, references(:workouts, on_delete: :nothing)
      add :exercise_id, references(:exercises, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:sets, [:workout_id])
    create index(:sets, [:exercise_id])
  end
end
