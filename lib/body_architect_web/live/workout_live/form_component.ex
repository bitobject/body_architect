defmodule BodyArchitectWeb.WorkoutLive.FormComponent do
  use BodyArchitectWeb, :live_component

  alias BodyArchitect.Workouts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage workout records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="workout-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Workout</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{workout: workout} = assigns, socket) do
    changeset = Workouts.change_workout(workout)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"workout" => workout_params}, socket) do
    changeset =
      socket.assigns.workout
      |> Workouts.change_workout(workout_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"workout" => workout_params}, socket) do
    save_workout(socket, socket.assigns.action, workout_params)
  end

  defp save_workout(socket, :edit, workout_params) do
    case Workouts.update_workout(socket.assigns.workout, workout_params) do
      {:ok, workout} ->
        notify_parent({:saved, workout})

        {:noreply,
         socket
         |> put_flash(:info, "Workout updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_workout(socket, :new, workout_params) do
    case Workouts.create_workout(workout_params) do
      {:ok, workout} ->
        notify_parent({:saved, workout})

        {:noreply,
         socket
         |> put_flash(:info, "Workout created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
