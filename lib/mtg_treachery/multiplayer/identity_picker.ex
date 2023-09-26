defmodule MtgTreachery.Multiplayer.IdentityPicker do
  def pick_identities(player_count, rarities) do
    identities = MtgTreachery.Multiplayer.list_identities()

    config = get_config(player_count)

    pick_identities_for_config(identities, config, rarities)
  end

  @doc """
  Given a player count, returns a map with :player_count => {:role, :number},
  where :role is a MTG Treachery role (Leader, Guardian, etc)
  and :number is the number of that role that should be in the game.
  """
  def get_config(player_count) do
    Application.app_dir(:mtg_treachery, "priv/configs/role-distributions.json")
    |> File.read!()
    |> Jason.decode!()
    |> Map.get(Integer.to_string(player_count))
  end

  @doc """
  Given a config of the type returned from `get_config` (:player_count => {:role, :number}),
  as well as a list of all possible identities and the desired rarity,
  pulls identities from the list of all identities based on the criteria in the config.
  """
  defp pick_identities_for_config(identities, config, rarities) do
    config
    |> Enum.flat_map(&pick_identities(&1, identities, rarities))
  end

  defp pick_identities({role, count}, identities, rarities) do
    identities
    |> Enum.filter(&is_valid_identity(&1, role, rarities))
    |> Enum.take_random(count)
  end

  # does the identity have the correct role and rarity?
  defp is_valid_identity(identity, role, rarities) do
    identity.role == role and
      Enum.member?(rarities, String.downcase(identity.rarity))
  end
end
