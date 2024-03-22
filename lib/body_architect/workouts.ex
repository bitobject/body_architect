defmodule BodyArchitect.Workouts do
  @moduledoc """
  The Workouts context.
  """

  import Ecto.Query, warn: false

  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Exercises.Exercise
  alias BodyArchitect.Repo
  alias BodyArchitect.Workouts.Workout

  @doc """
  Returns the list of workouts.

  ## Examples

      iex> list_workouts()
      [%Workout{}, ...]

  """
  def list_workouts(user_id) do
    Workout
    |> where([w], w.user_id == ^user_id)
    |> join(:left, [w], s in Set, on: w.id == s.workout_id)
    |> join(:left, [w, s], e in Exercise, on: s.exercise_id == e.id)
    # |> preload([w, s, e], exercises: {e, sets: s})
    |> order_by([w, s, e], [w.id, e.id, s.id])
    |> select([w, s, e], [w, e, s])
    |> Repo.all()
  end

  @doc false
  def list_workouts_with_preloads(user_id) do
    user_id
    |> list_workouts()
    |> Enum.reduce([], fn
      [%Workout{} = workout, %Exercise{} = exercise, %Set{} = set], acc ->
        if set.workout_id == workout.id and exercise.id == set.exercise_id do
          [[workout, exercise, set] | acc]
        else
          acc
        end

      [workout, exercise, set], acc ->
        [[workout, exercise, set] | acc]
    end)
    |> Enum.group_by(&hd(&1), &tl(&1))
    |> Enum.map(fn {workout, data_withot_workout} ->
      res = parse_exercises(data_withot_workout)
      %{workout | exercises: res}
    end)
  end

  defp parse_exercises(data) do
    data
    |> Stream.filter(&hd(&1))
    |> Stream.filter(&tl(&1))
    |> Enum.group_by(&hd(&1), &tl(&1))
    |> Enum.map(fn
      {exercise, data_withot_exercise} ->
        %{exercise | sets: List.flatten(data_withot_exercise)}

      {nil, _data_withot_exercise} ->
        []
    end)
  end

  @doc """
  Gets a single workout.

  Raises `Ecto.NoResultsError` if the Workout does not exist.

  ## Examples

      iex> get_workout!(123)
      %Workout{}

      iex> get_workout!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workout!(id) do
    Workout
    |> where([w], w.id == ^id)
    |> join(:left, [w], s in Set, on: w.id == s.workout_id)
    |> join(:left, [w, s], e in Exercise, on: s.exercise_id == e.id)
    |> preload([w, s, e], exercises: {e, sets: s})
    |> order_by([w, s, e], [w.id, e.id, s.id])
    |> Repo.one!()
  end

  @doc """
  Creates a workout.

  ## Examples

      iex> create_workout(%{field: value})
      {:ok, %Workout{}}

      iex> create_workout(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workout(attrs \\ %{}) do
    %Workout{}
    |> Workout.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a workout.

  ## Examples

      iex> update_workout(workout, %{field: new_value})
      {:ok, %Workout{}}

      iex> update_workout(workout, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workout(%Workout{} = workout, attrs) do
    workout
    |> Workout.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a workout.

  ## Examples

      iex> delete_workout(workout)
      {:ok, %Workout{}}

      iex> delete_workout(workout)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workout(%Workout{} = workout) do
    Repo.delete(workout)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workout changes.

  ## Examples

      iex> change_workout(workout)
      %Ecto.Changeset{data: %Workout{}}

  """
  def change_workout(%Workout{} = workout, attrs \\ %{}) do
    Workout.changeset(workout, attrs)
  end
end
