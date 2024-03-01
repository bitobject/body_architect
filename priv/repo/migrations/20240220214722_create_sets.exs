defmodule BodyArchitect.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :reps, :integer
      add :weight, :float
      add :completed, :boolean, default: false
      add :workout_id, references(:workouts, on_delete: :delete_all)
      add :exercise_id, references(:exercises, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:sets, [:workout_id])
    create index(:sets, [:exercise_id])
  end
end
