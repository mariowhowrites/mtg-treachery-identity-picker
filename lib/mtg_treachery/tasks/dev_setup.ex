defmodule Mix.Tasks.DevSetup do
  alias MtgTreachery.Repo
  alias MtgTreachery.Multiplayer.Identity
  use Mix.Task

  def run(_) do
    all_identities = Identity.all()

    for identity_chunk <- Enum.chunk_every(all_identities, 10) do
      Repo.insert_all(Identity, identity_chunk)
    end
  end
end
