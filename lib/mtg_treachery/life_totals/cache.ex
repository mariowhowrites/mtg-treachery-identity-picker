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
    case existing_process(game_id) do
      nil ->
        new_process(game_id)

      pid ->
        pid
    end
  end

  defp existing_process(game_id) do
    Server.whereis(game_id)
  end

  defp new_process(game_id) do
    case DynamicSupervisor.start_child(__MODULE__, {Server, game_id}) do
      {:ok, pid} ->
        pid
      {:error, {:already_started, pid}} ->
        pid
    end
  end
end
