defmodule MtgTreachery.MultiplayerTest do
  use MtgTreachery.DataCase

  alias MtgTreachery.Multiplayer

  describe "games" do
    alias MtgTreachery.Multiplayer.Game

    import MtgTreachery.MultiplayerFixtures

    @invalid_attrs %{code: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Multiplayer.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Multiplayer.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{code: "some code"}

      assert {:ok, %Game{} = game} = Multiplayer.create_game(valid_attrs)
      assert game.code == "some code"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Multiplayer.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{code: "some updated code"}

      assert {:ok, %Game{} = game} = Multiplayer.update_game(game, update_attrs)
      assert game.code == "some updated code"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Multiplayer.update_game(game, @invalid_attrs)
      assert game == Multiplayer.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Multiplayer.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Multiplayer.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Multiplayer.change_game(game)
    end
  end
end
