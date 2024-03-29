defmodule BodyArchitectWeb.WorkoutLive.Calendar do
  alias BodyArchitect.Exercises
  alias BodyArchitect.Repo
  alias BodyArchitect.Sets
  alias BodyArchitect.Sets.Set
  alias BodyArchitect.Workouts
  alias BodyArchitect.Workouts.Workout

  use BodyArchitectWeb, :live_view

  alias BodyArchitect.Workouts

  @week_start_at :monday

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    current_date = Date.utc_today()
    all_workouts = Workouts.list_workouts_with_preloads(current_user.id)

    assigns = [
      current_date: current_date,
      selected_date: nil,
      week_rows: week_rows(current_date),
      workouts: Enum.group_by(all_workouts, fn d -> d.date end),
      workout: nil,
      statistic: calculate_statistic(all_workouts)
    ]

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:selected_date, nil)
  end

  defp apply_action(socket, :new_workout, %{"date" => date}) do
    socket
    |> assign(:selected_date, Date.from_iso8601!(date))
    |> assign(:live_action, :new_workout)
    |> assign(:page_title, "New Workoout")
    |> assign(:workout, %Workout{exercises: [], date: date})
  end

  defp apply_action(socket, :show_date, %{"date" => date}) do
    socket
    |> assign(:selected_date, Date.from_iso8601!(date))
    |> assign(:live_action, :calendar_date)
  end

  def handle_event("prev-month", _, socket) do
    new_date = socket.assigns.current_date |> Date.beginning_of_month() |> Date.add(-1)

    assigns = [
      current_date: new_date,
      week_rows: week_rows(new_date)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("next-month", _, socket) do
    new_date = socket.assigns.current_date |> Date.end_of_month() |> Date.add(1)

    assigns = [
      current_date: new_date,
      week_rows: week_rows(new_date)
    ]

    {:noreply, assign(socket, assigns)}
  end

  @impl true
  def handle_info({BodyArchitectWeb.WorkoutLive.FormComponent, {:saved, workout}}, socket) do
    current_user = socket.assigns.current_user
    all_workouts = Workouts.list_workouts_with_preloads(current_user.id)

    {:noreply, assign(socket, :workouts, Enum.group_by(all_workouts, fn d -> d.date end))}
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
    type = workout_params["type"]

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :workout,
      Workouts.change_workout(%Workout{}, workout_params)
    )
    |> Ecto.Multi.insert_all(:sets, Set, fn %{workout: workout} ->
      Enum.map(workout_params["exercises"] || [], fn exercise_id ->
        exercise_id = String.to_integer(exercise_id)
        sets = Sets.list_sets_by([exercise_id: exercise_id], workout_type: type)

        new_sets =
          if sets == [] do
            []
          else
            [last | _prev] = sets

            sets
            |> Stream.filter(fn prev_set ->
              last.workout_id == prev_set.workout_id and type == prev_set.workout.type
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

  defp week_rows(current_date) do
    first =
      current_date
      |> Date.beginning_of_month()
      |> Date.beginning_of_week(@week_start_at)

    last =
      current_date
      |> Date.end_of_month()
      |> Date.end_of_week(@week_start_at)

    Date.range(first, last)
    |> Enum.map(& &1)
    |> Enum.chunk_every(7)
  end

  defp selected_date?(day, selected_date), do: day == selected_date

  defp today?(day), do: day == Date.utc_today()

  defp other_month?(day, current_date),
    do: Date.beginning_of_month(day) != Date.beginning_of_month(current_date)

  def calculate_statistic(workouts) do
    Enum.reduce(workouts, {0, 0, 0}, fn workout,
                                        {total_weight, total_sets, total_workout_count} ->
      Enum.reduce(
        workout.exercises,
        {total_weight, total_sets, total_workout_count + 1},
        fn exercise, {weight, sets, workout_count} ->
          if is_list(exercise.sets) do
            Enum.reduce(exercise.sets, {weight, sets, workout_count}, fn
              %Set{} = set,
              {inner_total_weight, inner_total_sets, inner_total_workout_count} = acc ->
                if set.completed do
                  {inner_total_weight + set.weight, inner_total_sets + 1,
                   inner_total_workout_count}
                else
                  acc
                end

              _field, acc ->
                acc
            end)
          else
            {weight, sets, workout_count}
          end
        end
      )
    end)
  end
end
