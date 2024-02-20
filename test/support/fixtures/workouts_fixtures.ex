defmodule BodyArchitect.WorkoutsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BodyArchitect.Workouts` context.
  """

  @doc """
  Generate a workout.
  """
  def workout_fixture(attrs \\ %{}) do
    {:ok, workout} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> BodyArchitect.Workouts.create_workout()

    workout
  end
end
