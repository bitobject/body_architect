defmodule BodyArchitect.Exercises.Exercise do
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Workouts.Workout
  alias BodyArchitect.Users.User

  use Ecto.Schema
  import Ecto.Changeset

  schema "exercises" do
    field :name, :string

    belongs_to :user, User
    has_many :sets, Set
    many_to_many :workouts, Workout, join_through: Set

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
