defmodule BodyArchitect.Sets.Set do
  use Ecto.Schema
  import Ecto.Changeset

  alias BodyArchitect.Workouts.Workout

  schema "sets" do
    field :completed, :boolean, default: false
    field :reps, :integer
    field :weight, :float, default: 0.0
    field :exercise_id, :id

    belongs_to :workout, Workout

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:reps, :weight, :completed, :workout_id, :exercise_id])
    |> validate_required([:reps, :weight])
  end
end
