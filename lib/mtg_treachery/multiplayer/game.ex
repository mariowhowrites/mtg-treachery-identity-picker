defmodule MtgTreachery.Multiplayer.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :game_code, :string
    field :player_count, :integer
    field :rarity, Ecto.Enum, values: [:uncommon, :rare, :mythic]

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:player_count, :rarity])
    |> validate_required([:player_count, :rarity])
    |> validate_number(:player_count, greater_than_or_equal_to: 4, less_than_or_equal_to: 8)
    |> generate_code()
    |> uppercase_rarity()
  end

  def generate_code(game) do
    put_change(game, :game_code, Ecto.UUID.generate())
  end

  defp uppercase_rarity(game) do
    IO.inspect(game)
    case Map.has_key?(game, :rarity) do
      true -> put_change(game, :rarity, String.capitalize(fetch_field(game, :rarity)))
      false -> game
    end
  end
end
