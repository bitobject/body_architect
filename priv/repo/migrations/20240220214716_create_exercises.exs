defmodule BodyArchitect.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
