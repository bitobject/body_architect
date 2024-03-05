defmodule BodyArchitectWeb.WorkoutLive.Show do
  use BodyArchitectWeb, :live_view

  alias BodyArchitect.Workouts
  alias BodyArchitect.Exercises.Exercise
  alias BodyArchitect.Exercises
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Sets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("set_delete", %{"id" => set_id}, socket) do
    set = Sets.get_set!(set_id)
    {:ok, _} = Sets.delete_set(set)

    {:noreply,
     socket
     |> assign(:workout, Workouts.get_workout!(socket.assigns.workout.id))
     |> assign(:set, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, Workouts.get_workout!(id))
    |> assign(:set, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, Workouts.get_workout!(id))
    |> assign(:set, nil)
  end

  defp apply_action(socket, :edit_set, %{"id" => id, "set_id" => set_id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, Workouts.get_workout!(id))
    |> assign(:exercises, Exercises.list_exercises())
    |> assign(:set, Sets.get_set!(set_id))
  end

  defp apply_action(socket, :add_set, %{"id" => id, "exercise_id" => exercise_id}) do
    workout = Workouts.get_workout!(id)
    int_exercise_id = String.to_integer(exercise_id)

    prev_set =
      workout.exercises
      |> Enum.find(%{}, fn %Exercise{} = exercise -> int_exercise_id == exercise.id end)
      |> Map.get(:sets, [])
      |> Enum.reverse()
      |> List.first()

    new_set =
      if prev_set do
        %Set{
          exercise_id: int_exercise_id,
          workout_id: workout.id,
          reps: prev_set.reps,
          weight: prev_set.weight
        }
      else
        %Set{exercise_id: int_exercise_id, workout_id: workout.id}
      end

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, workout)
    |> assign(:exercises, Exercises.list_exercises())
    |> assign(:set, new_set)
  end

  defp apply_action(socket, :new_set, %{"id" => id}) do
    workout = Workouts.get_workout!(id)

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, workout)
    |> assign(:exercises, Exercises.list_exercises())
    |> assign(:set, %Set{workout_id: workout.id})
  end

  defp page_title(:show), do: "Show Workout"
  defp page_title(:edit), do: "Edit Workout"
  defp page_title(:edit_set), do: "Edit Set"
  defp page_title(:add_set), do: "Add Set"
  defp page_title(:new_set), do: "New Set"

  defp calculate_progress(%{} = exercise) do
    {completed, all} =
      Enum.reduce(exercise.sets, {0, 0}, fn
        %Set{} = set, {completed, all} ->
          if set.completed do
            {completed + 1, all + 1}
          else
            {completed, all + 1}
          end

        _field, acc ->
          acc
      end)

    case {completed, all} do
      {0, 0} ->
        100

      {completed, all} ->
        round(completed / all * 100)
    end
  end

  defp calculate_progress(_) do
    0.0
  end

  defp calculate_progress_workout(%{} = workout) do
    {completed, all} =
      Enum.reduce(workout.exercises, {0, 0}, fn exercise, acc ->
        {completed, all} =
          if is_list(exercise.sets) do
            Enum.reduce(exercise.sets, acc, fn
              %Set{} = set, {completed, all} ->
                if set.completed do
                  {completed + 1, all + 1}
                else
                  {completed, all + 1}
                end

              _field, acc ->
                acc
            end)
          else
            acc
          end
      end)

    case {completed, all} do
      {0, 0} ->
        100

      {completed, all} ->
        round(completed / all * 100)
    end
  end

  defp calculate_progress_workout(_) do
    0.0
  end
end
