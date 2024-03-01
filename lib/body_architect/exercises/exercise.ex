defmodule BodyArchitect.Exercises.Exercise do
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Workouts.Workout

  use Ecto.Schema
  import Ecto.Changeset

  schema "exercises" do
    field :name, :string

    has_many :sets, Set
    many_to_many :workouts, Workout, join_through: Set

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
