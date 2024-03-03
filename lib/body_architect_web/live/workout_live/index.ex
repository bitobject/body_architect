defmodule BodyArchitectWeb.WorkoutLive.Index do
  use BodyArchitectWeb, :live_view

  alias BodyArchitect.Workouts
  alias BodyArchitect.Workouts.Workout

  @impl true
  def mount(_params, _session, socket) do
    all_workouts = Workouts.list_workouts()
    {:ok,
    stream(socket, :workouts, all_workouts)
    |> assign(:workouts_with_dates, Enum.group_by(all_workouts, fn d -> d.date end))
  }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Workout")
    |> assign(:workout, Workouts.get_workout!(id))
  end

  defp apply_action(socket, :new, %{"date" => date}) do
    socket
    |> assign(:page_title, "New Workout")
    |> assign(:workout, %Workout{exercises: [], date: date})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Workout")
    |> assign(:workout, %Workout{exercises: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Workouts")
    |> assign(:workout, nil)
  end

  @impl true
  def handle_info({BodyArchitectWeb.WorkoutLive.FormComponent, {:saved, workout}}, socket) do
    {:noreply, stream_insert(socket, :workouts, workout)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    workout = Workouts.get_workout!(id)
    {:ok, _} = Workouts.delete_workout(workout)

    {:noreply, stream_delete(socket, :workouts, workout)}
  end
end
