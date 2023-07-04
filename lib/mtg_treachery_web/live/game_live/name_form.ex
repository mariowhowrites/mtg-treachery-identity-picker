defmodule MtgTreacheryWeb.GameLive.NameForm do
  use Ecto.Schema
  import Ecto.Changeset

  alias MtgTreacheryWeb.GameLive.NameForm

  embedded_schema do
    field :name, :string
  end

  def name_changeset(attrs, game) do
    existing_player_names = Enum.map(game.players, fn p -> p.name end)

    cast(%NameForm{}, attrs, [:name])
    |> validate_required([:name])
    |> validate_exclusion(:name, existing_player_names)
  end
end
