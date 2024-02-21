defmodule BodyArchitect.SetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BodyArchitect.Sets` context.
  """

  @doc """
  Generate a set.
  """
  def set_fixture(attrs \\ %{}) do
    {:ok, set} =
      attrs
      |> Enum.into(%{
        reps: 42,
        weight: 120.5
      })
      |> BodyArchitect.Sets.create_set()

    set
  end
end
