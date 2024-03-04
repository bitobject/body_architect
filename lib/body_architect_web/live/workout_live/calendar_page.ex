defmodule BodyArchitectWeb.WorkoutLive.CalendarPageComponent do
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
        <%= @date %>
        <:subtitle>
          <.link
            patch={~p"/workouts/new?date=#{Calendar.strftime(@date, "%Y-%m-%d")}"}
            class="text-zinc-400 "
          >
            <div>
              <.icon name="hero-plus" class="h-6 w-6" />
            </div>
          </.link>
        </:subtitle>
      </.header>

      <div class="h-20 w-14 truncate">
        <div :for={workout <- @workouts[@date] || []} class="uppercase p-2">
          <.link navigate={~p"/workouts/#{workout}"}><%= workout.name %></.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
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
            |> Enum.filter(fn prev_set ->
              last.workout_id == prev_set.workout_id
            end)
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
