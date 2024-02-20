defmodule BodyArchitect.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create table(:workouts) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
