defmodule BodyArchitectWeb.ExerciseLive.Index do
  use BodyArchitectWeb, :live_view

  alias BodyArchitect.Exercises
  alias BodyArchitect.Exercises.Exercise

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    {:ok, stream(socket, :exercises, Exercises.list_exercises(current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Exercise")
    |> assign(:exercise, Exercises.get_exercise!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Exercise")
    |> assign(:exercise, %Exercise{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Exercises")
    |> assign(:exercise, nil)
  end

  @impl true
  def handle_info({BodyArchitectWeb.ExerciseLive.FormComponent, {:saved, exercise}}, socket) do
    {:noreply, stream_insert(socket, :exercises, exercise)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    exercise = Exercises.get_exercise!(id)
    {:ok, _} = Exercises.delete_exercise(exercise)

    {:noreply, stream_delete(socket, :exercises, exercise)}
  end
end
