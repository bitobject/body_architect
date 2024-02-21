defmodule BodyArchitect.ExercisesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BodyArchitect.Exercises` context.
  """

  @doc """
  Generate a exercise.
  """
  def exercise_fixture(attrs \\ %{}) do
    {:ok, exercise} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> BodyArchitect.Exercises.create_exercise()

    exercise
  end
end
