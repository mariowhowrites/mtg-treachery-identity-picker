defmodule MtgTreachery.Multiplayer.Identity do
  use Ecto.Schema

  alias MtgTreachery.Airtable.Client
  alias MtgTreachery.Multiplayer.Player
  # the cached json of all Treachery identities
  @identities_path "data/identities.json"

  schema "identities" do
    field(:name, :string)
    field(:role, :string)
    field(:description, :string)
    field(:unveil_cost, :string)
    field(:rarity, :string)

    has_many(:players, Player)
  end

  def all() do
    raw_identities =
      case File.exists?(@identities_path) do
        true -> Jason.decode!(File.read!(@identities_path))
        false -> fetch_identities()
      end

    convert_raw_identities(raw_identities)
  end

  # def get_by_name(name) do
  #   all_identities
  # end

  defp fetch_identities() do
    identities = Client.get_identities()

    File.write!(@identities_path, Jason.encode!(identities))

    identities
  end

  defp convert_raw_identities(raw_identities) do
    Enum.map(raw_identities, fn identity ->
      for {key, val} <- identity, into: %{} do
        {
          key
          |> String.downcase()
          |> String.replace(" ", "_")
          |> String.to_atom(),
          val
        }
      end
    end)
  end
end
