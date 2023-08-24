defmodule MtgTreachery.Multiplayer.IdentityPicker do

  def pick_identities(player_count, rarities) do
    identities = MtgTreachery.Multiplayer.list_identities()

    config = get_config(player_count)

    get_identities_for_config(identities, config, rarities)
  end

  @doc """
  Given a player count, returns a map with :player_count => {:role, :number},
  where :role is a MTG Treachery role (Leader, Guardian, etc)
  and :number is the number of that role that should be in the game.
  """
  defp get_config(player_count) do
    all_configs = Jason.decode!(
      File.read!(Application.app_dir(:mtg_treachery, "priv/configs/role-distributions.json"))
      )

    Map.get(all_configs, Integer.to_string(player_count))
  end

  @doc """
  Given a config of the type returned from `get_config` (:player_count => {:role, :number}),
  as well as a list of all possible identities and the desired rarity,
  pulls identities from the list of all identities based on the criteria in the config.
  """
  defp get_identities_for_config(identities, config, rarities) do
    Enum.flat_map(config, fn {role, count} ->
      all_possible_identities = get_all_possible_identities(identities, role, rarities)

      Enum.take_random(all_possible_identities, count)
    end)
  end

  defp get_all_possible_identities(identities, role, rarities) do
    Enum.filter(identities, fn possible_identity ->
      possible_identity.role == role and Enum.member?(rarities, String.downcase(possible_identity.rarity))
    end)
  end
end
