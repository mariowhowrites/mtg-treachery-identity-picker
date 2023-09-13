defmodule MtgTreachery.LifeTotals.Server do
  use GenServer, restart: :temporary

  alias MtgTreachery.LifeTotals.ProcessRegistry
  alias MtgTreachery.Multiplayer.Game

  # CLIENT FNS
  def start_link({game_id, players}) do
    GenServer.start_link(__MODULE__, {game_id, players}, name: via_tuple(game_id))
  end

  def get(server) do
    GenServer.call(server, {:get})
  end

  def add_player(server, player_id) do
    GenServer.cast(server, {:add_player, player_id})
  end

  def gain_life(server, player_id) do
    GenServer.cast(server, {:gain_life, player_id})
  end

  def lose_life(server, player_id) do
    GenServer.cast(server, {:lose_life, player_id})
  end

  def shutdown(server) do
    GenServer.stop(server)
  end

  defp via_tuple(game_id) do
    ProcessRegistry.via_tuple({__MODULE__, game_id})
  end

  # SERVER FNS
  # init arg takes a game object and returns a list of all players at life total = 40 (but can be made less )
  def init({game_id, players}) do
    case players != %{} and Ecto.assoc_loaded?(players) do
      true ->
        {:ok, {game_id, make_life_totals_map(players)}}

      false ->
        {:ok, {game_id, %{}}}
    end
  end

  def handle_call({:get}, _from, {game_id, life_totals}) do
    {:reply, life_totals, {game_id, life_totals}}
  end

  def handle_cast({:add_player, player_id}, {game_id, life_totals}) do
    new_life_totals = Map.put(life_totals, player_id, 40)

    Game.broadcast_life_totals(game_id, new_life_totals)

    {:noreply, {game_id, new_life_totals}}
  end

  def handle_cast({:gain_life, player_id}, {game_id, life_totals}) do
    new_life_totals =
      Map.put(
        life_totals,
        String.to_integer(player_id),
        Map.get(life_totals, String.to_integer(player_id)) + 1
      )

    Game.broadcast_life_totals(game_id, new_life_totals)

    {:noreply, {game_id, new_life_totals}}
  end

  def handle_cast({:lose_life, player_id}, {game_id, life_totals}) do
    new_life_totals =
      Map.put(
        life_totals,
        String.to_integer(player_id),
        Map.get(life_totals, String.to_integer(player_id)) -1
      )

    Game.broadcast_life_totals(game_id, new_life_totals)

    {:noreply, {game_id, new_life_totals}}
  end

  defp make_life_totals_map(players) do
    for player <- players, into: %{}, do: {player.id, player.life}
  end
end
