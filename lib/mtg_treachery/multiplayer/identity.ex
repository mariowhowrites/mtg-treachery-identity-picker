defmodule MtgTreachery.Multiplayer.Identity do
  use Ecto.Schema

  alias MtgTreachery.Multiplayer.Player

  schema "identities" do
    field(:name, :string)
    field(:role, :string)
    field(:description, :string)
    field(:unveil_cost, :string)
    field(:rarity, :string)

    has_many(:players, Player)
  end

  @doc """
  Returns all available identities from the JSON configuration file.
  The identities are cached in memory for better performance.
  """
  def all do
    Application.get_env(:mtg_treachery, :identities) ||
      load_identities()
  end

  @doc """
  Loads identities from the JSON file and caches them in the application environment.
  """
  def load_identities do
    identities =
      Application.app_dir(:mtg_treachery, "priv/configs/identities.json")
      |> File.read!()
      |> Jason.decode!()
      |> convert_raw_identities()

    Application.put_env(:mtg_treachery, :identities, identities)
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

  def slug(identity) do
    identity.name |> String.downcase() |> String.replace(" ", "_")
  end
end
