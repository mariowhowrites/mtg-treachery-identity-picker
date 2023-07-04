defmodule MtgTreachery.Multiplayer.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias MtgTreachery.Multiplayer.Game
  alias MtgTreachery.Multiplayer.Identity
  alias Phoenix.PubSub

  @pubsub MtgTreachery.PubSub

  schema "players" do
    field :user_uuid, :string
    field :name, :string, default: "New Player"
    field :creator, :boolean, default: false
    field :status, Ecto.Enum, values: [:veiled, :unveiled, :inactive], default: :veiled

    belongs_to :game, Game
    belongs_to :identity, Identity

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_uuid, :name, :creator, :status])
    |> validate_required([:user_uuid, :name])
  end
end
