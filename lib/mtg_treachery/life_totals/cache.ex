defmodule MtgTreachery.LifeTotals.Cache do
  alias MtgTreachery.LifeTotals.Server

  def start_link() do
    IO.puts("Starting life total cache")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(game_id, players \\ %{}) do
    case start_child(game_id, players) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(game_id, players) do
    DynamicSupervisor.start_child(__MODULE__, {Server, {game_id, players}})
  end
end
