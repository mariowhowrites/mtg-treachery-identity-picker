defmodule Mix.Tasks.DevSetup do
  alias MtgTreachery.Multiplayer
  use Mix.Task

  def run(_) do
    # Start the application
    {:ok, _} = Application.ensure_all_started(:mtg_treachery)

    Multiplayer.import_all_identities()
  end
end
