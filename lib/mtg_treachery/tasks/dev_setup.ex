defmodule Mix.Tasks.DevSetup do
  alias MtgTreachery.Repo
  alias MtgTreachery.Multiplayer
  use Mix.Task

  def run(_) do
    Multiplayer.import_all_identities()
  end
end
