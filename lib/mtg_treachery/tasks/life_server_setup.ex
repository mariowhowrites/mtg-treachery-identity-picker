defmodule MtgTreachery.Tasks.LifeServerSetup do
  use Task

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    MtgTreachery.Multiplayer.list_games()
    |> Enum.map(
      &(MtgTreachery.LifeTotals.Cache.server_process(&1.id, &1.players))
    )
  end
end
