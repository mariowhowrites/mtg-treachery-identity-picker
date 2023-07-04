defmodule MtgTreachery.Multiplayer.IdentityPicker do
  @configs_path "data/configs.json"

  def pick_identities(player_count, rarity) do
    identities = MtgTreachery.Multiplayer.list_identities()

    config = get_config(player_count)

    get_identities_for_config(identities, config, rarity)
  end

  @doc """
  Given a player count, returns a map with :player_count => {:role, :number},
  where :role is a MTG Treachery role (Leader, Guardian, etc)
  and :number is the number of that role that should be in the game.
  """
  defp get_config(player_count) do
    all_configs = Jason.decode!(File.read!(@configs_path))

    Map.get(all_configs, Integer.to_string(player_count))
  end

  @doc """
  Given a config of the type returned from `get_config` (:player_count => {:role, :number}),
  as well as a list of all possible identities and the desired rarity,
  pulls identities from the list of all identities based on the criteria in the config.
  """
  defp get_identities_for_config(identities, config, rarity) do
    Enum.flat_map(config, fn {role, count} ->
      all_possible_identities = get_all_possible_identities(identities, role, rarity)

      Enum.take_random(all_possible_identities, count)
    end)
  end

  defp get_all_possible_identities(identities, role, rarity) do
    Enum.filter(identities, fn possible_identity ->
      possible_identity.role == role and String.to_atom(String.downcase(possible_identity.rarity)) == rarity
    end)
  end
end
