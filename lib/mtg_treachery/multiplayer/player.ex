defmodule MtgTreachery.Multiplayer.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias MtgTreachery.Multiplayer.Game

  schema "players" do
    field :user_uuid, :string
    field :name, :string, default: "New Player"
    field :creator, :boolean, default: false
    field :status, Ecto.Enum, values: [:veiled, :unveiled, :inactive], default: :veiled
    field :life, :integer, default: 40
    field :identity_name, :string
    field :identity_role, :string
    field :identity_description, :string
    field :identity_unveil_cost, :string
    field :identity_rarity, :string

    belongs_to :game, Game

    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :user_uuid,
      :name,
      :creator,
      :status,
      :identity_name,
      :identity_role,
      :identity_description,
      :identity_unveil_cost,
      :identity_rarity
    ])
    |> validate_required([:user_uuid, :name])
  end

  def settings_changeset(player, attrs) do
    player
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def name_changeset(player, attrs) do
    player
    |> cast(attrs, [:name])
    |> validate_required(:name)
  end

  def identity(player) do
    %{
      name: player.identity_name,
      role: player.identity_role,
      description: player.identity_description,
      unveil_cost: player.identity_unveil_cost,
      rarity: player.identity_rarity
    }
  end
end
