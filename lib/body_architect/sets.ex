defmodule BodyArchitect.Sets do
  @moduledoc """
  The Sets context.
  """

  import Ecto.Query, warn: false
  alias BodyArchitect.Repo

  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Workouts.Workout

  @doc """
  Returns the list of sets.

  ## Examples

      iex> list_sets()
      [%Set{}, ...]

  """
  def list_sets do
    Repo.all(Set)
  end

  def list_sets_by(params, additional_params \\ []) do
    workout_type = Keyword.get(additional_params, :workout_type)

    Set
    |> join(:left, [s], w in Workout, on: w.id == s.workout_id)
    |> where(^params)
    |> order_by(desc: :id)
    |> limit(20)
    |> preload([s, w], workout: w)
    |> maybe_add_workout_type(workout_type)
    |> Repo.all()
  end

  defp maybe_add_workout_type(query, nil), do: query
  defp maybe_add_workout_type(query, type), do: where(query, [s, w], w.type == ^type)

  @doc """
  Gets a single set.

  Raises `Ecto.NoResultsError` if the Set does not exist.

  ## Examples

      iex> get_set!(123)
      %Set{}

      iex> get_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_set!(id), do: Repo.get!(Set, id)

  @doc """
  Creates a set.

  ## Examples

      iex> create_set(%{field: value})
      {:ok, %Set{}}

      iex> create_set(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_set(attrs \\ %{}) do
    %Set{}
    |> Set.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a set.

  ## Examples

      iex> update_set(set, %{field: new_value})
      {:ok, %Set{}}

      iex> update_set(set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_set(%Set{} = set, attrs) do
    set
    |> Set.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a set.

  ## Examples

      iex> delete_set(set)
      {:ok, %Set{}}

      iex> delete_set(set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_set(%Set{} = set) do
    Repo.delete(set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking set changes.

  ## Examples

      iex> change_set(set)
      %Ecto.Changeset{data: %Set{}}

  """
  def change_set(%Set{} = set, attrs \\ %{}) do
    Set.changeset(set, attrs)
  end
end
