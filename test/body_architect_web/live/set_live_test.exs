defmodule BodyArchitectWeb.SetLiveTest do
  use BodyArchitectWeb.ConnCase

  import Phoenix.LiveViewTest
  import BodyArchitect.SetsFixtures

  @create_attrs %{reps: 42, weight: 120.5}
  @update_attrs %{reps: 43, weight: 456.7}
  @invalid_attrs %{reps: nil, weight: nil}

  defp create_set(_) do
    set = set_fixture()
    %{set: set}
  end

  describe "Index" do
    setup [:create_set]

    test "lists all sets", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/sets")

      assert html =~ "Listing Sets"
    end

    test "saves new set", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/sets")

      assert index_live |> element("a", "New Set") |> render_click() =~
               "New Set"

      assert_patch(index_live, ~p"/sets/new")

      assert index_live
             |> form("#set-form", set: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#set-form", set: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/sets")

      html = render(index_live)
      assert html =~ "Set created successfully"
    end

    test "updates set in listing", %{conn: conn, set: set} do
      {:ok, index_live, _html} = live(conn, ~p"/sets")

      assert index_live |> element("#sets-#{set.id} a", "Edit") |> render_click() =~
               "Edit Set"

      assert_patch(index_live, ~p"/sets/#{set}/edit")

      assert index_live
             |> form("#set-form", set: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#set-form", set: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/sets")

      html = render(index_live)
      assert html =~ "Set updated successfully"
    end

    test "deletes set in listing", %{conn: conn, set: set} do
      {:ok, index_live, _html} = live(conn, ~p"/sets")

      assert index_live |> element("#sets-#{set.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sets-#{set.id}")
    end
  end

  describe "Show" do
    setup [:create_set]

    test "displays set", %{conn: conn, set: set} do
      {:ok, _show_live, html} = live(conn, ~p"/sets/#{set}")

      assert html =~ "Show Set"
    end

    test "updates set within modal", %{conn: conn, set: set} do
      {:ok, show_live, _html} = live(conn, ~p"/sets/#{set}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Set"

      assert_patch(show_live, ~p"/sets/#{set}/show/edit")

      assert show_live
             |> form("#set-form", set: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#set-form", set: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/sets/#{set}")

      html = render(show_live)
      assert html =~ "Set updated successfully"
    end
  end
end
