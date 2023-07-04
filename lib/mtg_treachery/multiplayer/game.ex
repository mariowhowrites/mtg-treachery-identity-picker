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
    field :rarity, Ecto.Enum, values: [:uncommon, :rare, :mythic]
    has_many :players, Player

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:player_count, :rarity, :status])
    |> validate_required([:player_count, :rarity, :status])
    |> validate_number(:player_count, greater_than_or_equal_to: 4, less_than_or_equal_to: 8)
    # |> uppercase_rarity()
  end

  # defp uppercase_rarity(game) do
  #   case Map.has_key?(game, :rarity) do
  #     true -> put_change(game, :rarity, String.capitalize(fetch_field(game, :rarity)))
  #     false -> game
  #   end
  # end
  def subscribe_game(game_id) do
    PubSub.subscribe(@pubsub, "game:#{game_id}")
  end

  def broadcast_game(game_id) do
    PubSub.broadcast(@pubsub, "game:#{game_id}", {:game, game_id})
  end
end
