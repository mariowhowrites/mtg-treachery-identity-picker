defmodule MtgTreachery.CronJobs.CleanupLifeTotalServers do
  alias MtgTreachery.Multiplayer
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()

    {:ok, state}
  end

  def handle_info(:work, state) do
    cleanup_old_life_total_servers(state)

    schedule_work()

    {:noreply, state}
  end

  defp cleanup_old_life_total_servers(state) do
    # get all games with creation dates older than a day from today
    get_old_games()
    # shut down associated life total servers
    |> Enum.each(&Multiplayer.end_game/1)
  end

  # get all games with creation dates older than a day from today
  defp get_old_games() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-1, :day)
    |> Multiplayer.get_games_older_than_datetime()
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000)
  end
end
