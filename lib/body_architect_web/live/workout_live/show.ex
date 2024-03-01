defmodule BodyArchitectWeb.WorkoutLive.Show do
  use BodyArchitectWeb, :live_view

  alias BodyArchitect.Workouts
  alias BodyArchitect.Exercises.Exercise
  alias BodyArchitect.Exercises
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Sets

  @impl true
  def mount(params, _session, socket) do
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
  def handle_params(params, url, socket) do
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

  defp apply_action(socket, :edit_set, %{"id" => id, "set_id" => set_id} = params) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, Workouts.get_workout!(id))
    |> assign(:exercises, Exercises.list_exercises())
    |> assign(:set, Sets.get_set!(set_id))
  end

  defp apply_action(socket, :add_set, %{"id" => id, "exercise_id" => exercise_id} = params) do
    workout = Workouts.get_workout!(id)

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:workout, workout)
    |> assign(:exercises, Exercises.list_exercises())
    |> assign(:set, %Set{exercise_id: exercise_id, workout_id: workout.id})
  end

  defp apply_action(socket, :new_set, %{"id" => id} = params) do
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
end
