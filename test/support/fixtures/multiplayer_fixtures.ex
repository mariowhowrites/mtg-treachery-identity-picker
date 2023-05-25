defmodule MtgTreachery.MultiplayerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MtgTreachery.Multiplayer` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        code: "some code"
      })
      |> MtgTreachery.Multiplayer.create_game()

    game
  end
end
