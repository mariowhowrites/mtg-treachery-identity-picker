defmodule MtgTreachery.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_code, :string
      add :player_count, :integer
      add :rarities, {:array, :string}
      add :status, :string

      timestamps()
    end
  end
end
