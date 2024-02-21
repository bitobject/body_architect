defmodule BodyArchitectWeb.ExerciseLiveTest do
  use BodyArchitectWeb.ConnCase

  import Phoenix.LiveViewTest
  import BodyArchitect.ExercisesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_exercise(_) do
    exercise = exercise_fixture()
    %{exercise: exercise}
  end

  describe "Index" do
    setup [:create_exercise]

    test "lists all exercises", %{conn: conn, exercise: exercise} do
      {:ok, _index_live, html} = live(conn, ~p"/exercises")

      assert html =~ "Listing Exercises"
      assert html =~ exercise.name
    end

    test "saves new exercise", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/exercises")

      assert index_live |> element("a", "New Exercise") |> render_click() =~
               "New Exercise"

      assert_patch(index_live, ~p"/exercises/new")

      assert index_live
             |> form("#exercise-form", exercise: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#exercise-form", exercise: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/exercises")

      html = render(index_live)
      assert html =~ "Exercise created successfully"
      assert html =~ "some name"
    end

    test "updates exercise in listing", %{conn: conn, exercise: exercise} do
      {:ok, index_live, _html} = live(conn, ~p"/exercises")

      assert index_live |> element("#exercises-#{exercise.id} a", "Edit") |> render_click() =~
               "Edit Exercise"

      assert_patch(index_live, ~p"/exercises/#{exercise}/edit")

      assert index_live
             |> form("#exercise-form", exercise: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#exercise-form", exercise: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/exercises")

      html = render(index_live)
      assert html =~ "Exercise updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes exercise in listing", %{conn: conn, exercise: exercise} do
      {:ok, index_live, _html} = live(conn, ~p"/exercises")

      assert index_live |> element("#exercises-#{exercise.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#exercises-#{exercise.id}")
    end
  end

  describe "Show" do
    setup [:create_exercise]

    test "displays exercise", %{conn: conn, exercise: exercise} do
      {:ok, _show_live, html} = live(conn, ~p"/exercises/#{exercise}")

      assert html =~ "Show Exercise"
      assert html =~ exercise.name
    end

    test "updates exercise within modal", %{conn: conn, exercise: exercise} do
      {:ok, show_live, _html} = live(conn, ~p"/exercises/#{exercise}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Exercise"

      assert_patch(show_live, ~p"/exercises/#{exercise}/show/edit")

      assert show_live
             |> form("#exercise-form", exercise: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#exercise-form", exercise: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/exercises/#{exercise}")

      html = render(show_live)
      assert html =~ "Exercise updated successfully"
      assert html =~ "some updated name"
    end
  end
end
