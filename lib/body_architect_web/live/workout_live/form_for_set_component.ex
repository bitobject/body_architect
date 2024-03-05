defmodule BodyArchitectWeb.WorkoutLive.FormForSetComponent do
  use BodyArchitectWeb, :live_component

  alias BodyArchitect.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex p-2 spacing truncate text-center leading-loose">
      <.form
        :let={f}
        for={@form}
        class=""
        id={@id || "set-form"}
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={f[:completed]} type="workout_checkbox" phx-change="save" class="" />
      </.form>
      <div class="px-2 w-16 "><%= @form.data.reps %></div>
      <div class="px-2 w-16 truncate"><%= @form.data.weight %></div>
      <.link patch={~p"/workouts/#{@form.data.workout_id}/sets/#{@form.data.id}/edit"}>
        <p class="px-2 w-16 truncate">Edit</p>
      </.link>
      <.link
        phx-click={JS.push("set_delete", value: %{id: @form.data.id}) |> hide("##{@form.data.id}")}
        data-confirm="Are you sure?"
      >
        <p class="px-2 w-16 truncate">Delete</p>
      </.link>
    </div>
    """
  end

  @impl true
  def update(%{set: set} = assigns, socket) do
    changeset = Sets.change_set(set)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"set" => set_params}, socket) do
    changeset =
      socket.assigns.set
      |> Sets.change_set(set_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"set" => set_params}, socket) do
    save_set(socket, set_params)
  end

  defp save_set(socket, set_params) do
    if socket.assigns.set |> Sets.change_set(set_params) |> Ecto.Changeset.apply_changes() ==
         socket.assigns.set do
      {:noreply, socket}
    else
      case Sets.update_set(socket.assigns.set, set_params) do
        {:ok, set} ->
          notify_parent({:saved, set})

          {:noreply,
           socket
           |> put_flash(:info, "Set updated successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
