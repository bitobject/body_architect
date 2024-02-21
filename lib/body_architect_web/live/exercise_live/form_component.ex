defmodule BodyArchitectWeb.ExerciseLive.FormComponent do
  use BodyArchitectWeb, :live_component

  alias BodyArchitect.Exercises

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage exercise records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="exercise-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Exercise</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{exercise: exercise} = assigns, socket) do
    changeset = Exercises.change_exercise(exercise)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"exercise" => exercise_params}, socket) do
    changeset =
      socket.assigns.exercise
      |> Exercises.change_exercise(exercise_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"exercise" => exercise_params}, socket) do
    save_exercise(socket, socket.assigns.action, exercise_params)
  end

  defp save_exercise(socket, :edit, exercise_params) do
    case Exercises.update_exercise(socket.assigns.exercise, exercise_params) do
      {:ok, exercise} ->
        notify_parent({:saved, exercise})

        {:noreply,
         socket
         |> put_flash(:info, "Exercise updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_exercise(socket, :new, exercise_params) do
    case Exercises.create_exercise(exercise_params) do
      {:ok, exercise} ->
        notify_parent({:saved, exercise})

        {:noreply,
         socket
         |> put_flash(:info, "Exercise created successfully")
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
