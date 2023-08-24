defmodule MtgTreachery.MultiplayerFixtures do
  alias MtgTreachery.Repo

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
        player_count: 5,
        rarities: ["uncommon"],
        status: :waiting
      })
      |> MtgTreachery.Multiplayer.create_game()

    game |> Repo.preload(:players)
  end
end
