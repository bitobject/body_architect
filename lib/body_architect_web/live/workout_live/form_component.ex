defmodule BodyArchitectWeb.WorkoutLive.FormComponent do
  alias BodyArchitect.Workouts.Workout
  alias BodyArchitect.Repo
  alias BodyArchitect.Sets
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Exercises
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
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:type]} type="select" options={["long", "short"]} label="Type" />
        <.input
          field={@form[:exercises]}
          multiple={true}
          type="select"
          options={@exercises}
          value="exercises"
        />
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

    exercises = Exercises.list_exercises() |> Enum.into([], fn x -> {x.name, x.id} end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:exercises, exercises)
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

  defp save_workout(socket, :new_workout, workout_params) do
    base_save_workout(socket, :new_workout, workout_params)
  end

  defp save_workout(socket, :new, workout_params) do
    base_save_workout(socket, :new, workout_params)
  end

  defp base_save_workout(socket, _action, workout_params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :workout,
      Workouts.change_workout(%Workout{}, workout_params)
    )
    |> Ecto.Multi.insert_all(:sets, Set, fn %{workout: workout} ->
      Enum.map(workout_params["exercises"], fn exercise_id ->
        exercise_id = String.to_integer(exercise_id)
        sets = Sets.list_sets_by(exercise_id: exercise_id)

        new_sets =
          if sets == [] do
            []
          else
            [last | _prev] = sets

            sets
            |> Stream.filter(fn prev_set ->
              last.workout_id == prev_set.workout_id
            end)
            |> Enum.reverse()
          end

        {exercise_id, new_sets}
      end)
      |> Enum.map(fn {exercise_id, list} ->
        if list == [] do
          %{
            exercise_id: exercise_id,
            workout_id: workout.id,
            reps: 20,
            weight: 0.0,
            completed: false,
            inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
            updated_at: DateTime.truncate(DateTime.utc_now(), :second)
          }
        else
          list
          |> Enum.map(fn prev_set ->
            %{
              exercise_id: exercise_id,
              workout_id: workout.id,
              reps: prev_set.reps,
              weight: prev_set.weight,
              completed: false,
              inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
              updated_at: DateTime.truncate(DateTime.utc_now(), :second)
            }
          end)
        end
      end)
      |> List.flatten()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{workout: workout}} ->
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
