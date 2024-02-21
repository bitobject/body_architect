defmodule BodyArchitect.SetsTest do
  use BodyArchitect.DataCase

  alias BodyArchitect.Sets

  describe "sets" do
    alias BodyArchitect.Sets.Set

    import BodyArchitect.SetsFixtures

    @invalid_attrs %{reps: nil, weight: nil}

    test "list_sets/0 returns all sets" do
      set = set_fixture()
      assert Sets.list_sets() == [set]
    end

    test "get_set!/1 returns the set with given id" do
      set = set_fixture()
      assert Sets.get_set!(set.id) == set
    end

    test "create_set/1 with valid data creates a set" do
      valid_attrs = %{reps: 42, weight: 120.5}

      assert {:ok, %Set{} = set} = Sets.create_set(valid_attrs)
      assert set.reps == 42
      assert set.weight == 120.5
    end

    test "create_set/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sets.create_set(@invalid_attrs)
    end

    test "update_set/2 with valid data updates the set" do
      set = set_fixture()
      update_attrs = %{reps: 43, weight: 456.7}

      assert {:ok, %Set{} = set} = Sets.update_set(set, update_attrs)
      assert set.reps == 43
      assert set.weight == 456.7
    end

    test "update_set/2 with invalid data returns error changeset" do
      set = set_fixture()
      assert {:error, %Ecto.Changeset{}} = Sets.update_set(set, @invalid_attrs)
      assert set == Sets.get_set!(set.id)
    end

    test "delete_set/1 deletes the set" do
      set = set_fixture()
      assert {:ok, %Set{}} = Sets.delete_set(set)
      assert_raise Ecto.NoResultsError, fn -> Sets.get_set!(set.id) end
    end

    test "change_set/1 returns a set changeset" do
      set = set_fixture()
      assert %Ecto.Changeset{} = Sets.change_set(set)
    end
  end
end
