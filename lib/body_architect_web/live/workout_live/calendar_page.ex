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
      <p class="text-gray-400 font-bold"><%= Calendar.strftime(@date, "%B %Y") %></p>
      <header class="flex pb-4">
        <h3 class="text-2xl font-extrabold mr-4">Workouts</h3>

        <.link
          patch={~p"/new_workout/#{Calendar.strftime(@date, "%Y-%m-%d")}"}
          class="flex items-center justify-center text-zinc-400"
        >
          <div class="mr-1">
            <.icon name="hero-plus" class="h-6 w-6 text-red-500" />
          </div>
          <div class="text-center font-extrabold max-w-40 uppercase text-red-400">
            add workout
          </div>
        </.link>
      </header>
      <hr class="" />
      <div class="truncate mt-4">
        <div
          :for={workout <- @workouts[@date] || []}
          class="flex items-center justify-center uppercase py-2 hover:bg-gray-50 rounded-xl"
        >
          <.link class="block w-full font-extrabold p-2 truncate" navigate={~p"/workouts/#{workout}"}>
            <%= workout.name %>
          </.link>
          <div class="flex w-full h-full max-w-60 items-center justify-center">
            <% progress = calculate_progress(workout) %>
            <div class="block w-14 shrink-0 px-2 font-bold text-zinc-500"><%= progress %>%</div>
            <div class="h-4 w-full  bg-gray-200 rounded-xl">
              <div
                class="text-zinc-50 flex items-center justify-center h-4 rounded-xl bg-gradient-to-r from-cyan-300 to-blue-500 text-center"
                style={"width: #{progress}%"}
              />
            </div>
          </div>
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

  defp calculate_progress(%{} = workout) do
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

  defp calculate_progress(_) do
    0.0
  end
end
