defmodule BodyArchitect.Sets.Set do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sets" do
    field :completed, :boolean, default: false
    field :reps, :integer
    field :weight, :float
    field :workout_id, :id
    field :exercise_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:reps, :weight, :completed, :workout_id, :exercise_id])
    |> validate_required([:reps, :weight])
  end
end
