defmodule MtgTreachery.Multiplayer.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias MtgTreachery.Multiplayer.Player
  alias Phoenix.PubSub

  @pubsub MtgTreachery.PubSub

  schema "games" do
    field :game_code, :string
    field :player_count, :integer, default: 5
    field :status, Ecto.Enum, values: [:waiting, :live, :inactive], default: :waiting
    field :rarities, {:array, :string}
    has_many :players, Player

    timestamps()
  end

  @rarity_options [
    {"Uncommon", "uncommon"},
    {"Rare", "rare"},
    {"Mythic Rare", "mythic"},
  ]

  def rarity_options, do: @rarity_options

  @valid_rarities Enum.map(@rarity_options, fn({_text, val}) -> val end)
  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:player_count, :rarities, :status])
    |> validate_required([:player_count, :rarities, :status])
    |> validate_number(:player_count, greater_than_or_equal_to: 4, less_than_or_equal_to: 8)
    |> validate_length(:rarities, min: 1, max: 3)
    |> validate_subset(:rarities, @valid_rarities)
  end

  def subscribe_game(game_id) do
    PubSub.subscribe(@pubsub, "game:#{game_id}")
  end

  def broadcast_game(game_id) do
    PubSub.broadcast(@pubsub, "game:#{game_id}", {:game, game_id})
  end

  def broadcast_game_start(game_id) do
    PubSub.broadcast(@pubsub, "game:#{game_id}", {:game_start})
  end

  def subscribe_life_totals(game_id) do
    PubSub.subscribe(@pubsub, "life_totals:#{game_id}")
  end

  def broadcast_life_totals(game_id, life_totals) do
    PubSub.broadcast(@pubsub, "life_totals:#{game_id}", {:life_totals, life_totals})
  end
end
