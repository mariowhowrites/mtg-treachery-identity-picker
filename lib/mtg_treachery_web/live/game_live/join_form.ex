defmodule MtgTreacheryWeb.GameLive.JoinForm do
  alias MtgTreacheryWeb.GameLive.JoinForm
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :game_code, :string
    field :name, :string
  end

  def game_code_changeset(attrs, all_game_codes) do
    cast(%JoinForm{}, attrs, [:game_code, :name])
    |> validate_required([:game_code, :name])
    |> validate_inclusion(:game_code, all_game_codes)
  end
end
