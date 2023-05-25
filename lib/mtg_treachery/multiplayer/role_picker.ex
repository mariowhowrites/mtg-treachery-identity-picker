defmodule MtgTreachery.Multiplayer.RolePicker do
  @configs_path "data/configs.json"

  def pick_roles(player_count, rarity) do
    roles = MtgTreachery.Multiplayer.Role.all()

    config = get_config(player_count)

    get_roles_for_config(roles, config, rarity)
  end

  defp get_config(player_count) do
    all_configs = Jason.decode!(File.read!(@configs_path))

    Map.get(all_configs, Integer.to_string(player_count))
  end

  defp get_roles_for_config(roles, config, rarity) do
    Enum.flat_map(config, fn {identity, count} ->
      all_possible_roles = get_all_possible_roles(roles, identity, rarity)

      Enum.take_random(all_possible_roles, count)
    end)
  end

  defp get_all_possible_roles(roles, identity, rarity) do
    Enum.filter(roles, fn possible_role ->
      possible_role.identity == identity and String.downcase(possible_role.rarity) == rarity
    end)
  end
end

# Given a player count and a rarity level, return a list of roles
