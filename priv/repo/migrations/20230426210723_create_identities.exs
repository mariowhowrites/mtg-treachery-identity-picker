defmodule MtgTreachery.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :description, :text
      add :name, :string
      add :role, :string
      add :rarity, :string
      add :unveil_cost, :string
    end
  end
end
