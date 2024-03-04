defmodule BodyArchitect.Workouts.Workout do
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Exercises.Exercise
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
    field :name, :string
    field :date, :date, default: NaiveDateTime.to_date(NaiveDateTime.utc_now())

    many_to_many :exercises, Exercise, join_through: Set

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:name, :date])
    |> validate_required([:name])
  end
end
