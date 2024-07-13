defmodule MtgTreachery.LifeTotals do
  alias MtgTreachery.LifeTotals.{Cache, Server}

  def get_life_totals_by_game_id(game_id) do
    game_id
    |> Cache.server_process()
    |> Server.get()
  end

  def add_player(game_id, player_id) do
    game_id
    |> Cache.server_process()
    |> Server.add_player(player_id)
  end

  def gain_life(game_id, player_id) do
    game_id
    |> Cache.server_process()
    |> Server.gain_life(player_id)
  end

  def lose_life(game_id, player_id) do
    game_id
    |> Cache.server_process()
    |> Server.lose_life(player_id)
  end

  def shutdown(game_id) do
    game_id
    |> Cache.server_process()
    |> Server.shutdown()
  end
end
