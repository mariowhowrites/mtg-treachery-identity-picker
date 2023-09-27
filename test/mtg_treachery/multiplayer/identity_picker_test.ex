defmodule MtgTreachery.Multiplayer.IdentityPickerTest do
  use MtgTreachery.DataCase

  alias MtgTreachery.Multiplayer.IdentityPicker
  alias MtgTreachery.Multiplayer

  setup do
    MtgTreachery.Multiplayer.import_all_identities()

    :ok
  end

  #
  # Tests
  #

  describe "identity_picker" do
    test "picks the correct amount of identities" do
      identities = IdentityPicker.pick_identities(5, ["uncommon"])

      assert length(identities) == 5
    end

    test "picks the correct balance of identities for each player count" do
      Enum.to_list(4..8)
      |> Enum.map(&assert_player_count_yields_expected_role_count/1)
    end

    test "picks the correct rarity of identities" do
      ["uncommon", "rare", "mythic"]
      |> Enum.each(fn rarity ->
        identities = IdentityPicker.pick_identities(5, [rarity])

        assert Enum.all?(identities, &(&1.rarity == String.capitalize(rarity)))
      end)
    end
  end

  #
  # Helpers
  #

  defp assert_player_count_yields_expected_role_count(player_count) do
    config = IdentityPicker.get_config(player_count)

    identities =
      IdentityPicker.pick_identities(player_count, ["uncommon"])
      |> Enum.group_by(& &1.role)

    assert Enum.all?(config, &has_expected_role_count(&1, identities))
  end

  defp has_expected_role_count({role, count}, identities) do
    # there is no guardian role in 4p games. if we are in 4p, guardian count should be 0 and the identities map should have no key for the guardian role
    # otherwise, check the relevant property of the identities map to ensure the role count is correct
    case Map.has_key?(identities, role) do
      false -> count == 0
      true -> count == length(Map.get(identities, role))
    end
  end
end
