defmodule MtgTreachery.Multiplayer.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias MtgTreachery.Multiplayer.Game
  alias MtgTreachery.Multiplayer.Identity

  schema "players" do
    field :user_uuid, :string
    field :name, :string, default: "New Player"
    field :creator, :boolean, default: false
    field :status, Ecto.Enum, values: [:veiled, :unveiled, :inactive], default: :veiled
    field :life, :integer, default: 40

    belongs_to :game, Game
    belongs_to :identity, Identity

    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:user_uuid, :name, :creator, :status])
    |> validate_required([:user_uuid, :name])
  end

  def settings_changeset(player, attrs) do
    player
    |> cast(attrs, [:identity_id, :name])
    |> validate_required([:name])
  end
end
