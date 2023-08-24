defmodule MtgTreachery.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :user_uuid, :string
      add :name, :string
      add :status, :string
      add :life, :integer, default: 40

      add :creator, :boolean, default: false
      add :game_id, references(:games)
      add :identity_id, references(:identities)

      timestamps()
    end
  end
end
