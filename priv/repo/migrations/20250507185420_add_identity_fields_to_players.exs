defmodule MtgTreachery.Repo.Migrations.AddIdentityFieldsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      # Remove the old identity_id field
      remove :identity_id

      # Add the new identity fields
      add :identity_name, :string
      add :identity_role, :string
      add :identity_description, :text
      add :identity_unveil_cost, :string
      add :identity_rarity, :string
    end
  end
end
