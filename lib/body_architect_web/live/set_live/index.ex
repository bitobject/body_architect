defmodule BodyArchitectWeb.SetLive.Index do
  use BodyArchitectWeb, :live_view

  alias BodyArchitect.Sets
  alias BodyArchitect.Sets.Set

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :sets, Sets.list_sets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Set")
    |> assign(:set, Sets.get_set!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Set")
    |> assign(:set, %Set{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sets")
    |> assign(:set, nil)
  end

  @impl true
  def handle_info({BodyArchitectWeb.SetLive.FormComponent, {:saved, set}}, socket) do
    {:noreply, stream_insert(socket, :sets, set)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    set = Sets.get_set!(id)
    {:ok, _} = Sets.delete_set(set)

    {:noreply, stream_delete(socket, :sets, set)}
  end
end
