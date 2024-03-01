defmodule BodyArchitectWeb.SetLive.FormComponent do
  use BodyArchitectWeb, :live_component

  alias BodyArchitect.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage set records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="set-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:reps]} type="number" label="Reps" />
        <.input field={@form[:weight]} type="number" label="Weight" step="any" />
        <.input field={@form[:completed]} type="checkbox" label="completed" step="any" />
        <.input
          field={@form[:exercise_id]}
          type="select"
          options={@exercises |> Enum.into([], fn x -> {x.name, x.id} end)}
          ,
          label="exercises"
          step="any"
        />
        <.input field={@form[:workout_id]} type="number" , label="workout" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Set</.button>
        </:actions>
      </.simple_form>
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
    save_set(socket, socket.assigns.action, set_params)
  end

  defp save_set(socket, :edit_set, set_params) do
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

  defp save_set(socket, :edit, set_params) do
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

  defp save_set(socket, :new, set_params) do
    case Sets.create_set(set_params) do
      {:ok, set} ->
        notify_parent({:saved, set})

        {:noreply,
         socket
         |> put_flash(:info, "Set created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_set(socket, :new_set, set_params) do
    case Sets.create_set(set_params) do
      {:ok, set} ->
        notify_parent({:saved, set})

        {:noreply,
         socket
         |> put_flash(:info, "Set created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_set(socket, :add_set, set_params) do
    case Sets.create_set(set_params) do
      {:ok, set} ->
        notify_parent({:saved, set})

        {:noreply,
         socket
         |> put_flash(:info, "Set created successfully")
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
