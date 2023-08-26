defmodule MtgTreacheryWeb.GameLive.Panels.LobbyPanel do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:is_editing_name, false)}
  end

  @impl true
  def render(assigns) do
    IO.inspect(assigns.life_totals)

    ~H"""
    <div class="h-full">
      <section class="h-full w-4/5 mx-auto py-6 flex flex-col items-center gap-2 w-full">
        <h3 class="hidden">Other Players</h3>
        <ul class={grid_wrapper_classes(@game)}>
          <%= for {player, index} <- other_players(@game, @current_player) do %>
            <li class={other_player_card_wrapper_style(player, index, @game)}>
              <div class="text-center h-full flex flex-col items-center justify-center">
                <span><%= player.name %></span>
                <%= if player.identity != nil do %>
                  <span><%= player.status %></span>
                  <%!-- test button, remove for prod --%>
                  <button phx-click="unveil_player" phx-value-player={player.id}>Toggle Veil</button>
                <% end %>
                <%= if player.identity != nil and player.status != :veiled do %>
                  <button phx-click="view_player" class="underline text-blue-600" phx-value-player-id={player.id}>
                    <%= player.identity.role %> - <%= player.identity.name %>
                  </button>
                <% end %>
                <span><%= @life_totals[player.id] %></span>
              </div>
            </li>
          <% end %>
          <%= for _empty_slot <- empty_slots(@game) do %>
            <li class="border-2 text-center bg-gray-100 flex justify-center items-center">
              Empty slot
            </li>
          <% end %>
        </ul>
      </section>
    </div>
    """
  end

  @impl true
  def handle_event("start_editing", _params, socket) do
    {:noreply, socket |> push_patch(to: ~p"/game/settings")}
  end

  defp empty_slots(game) do
    case Multiplayer.is_game_full(game) do
      true ->
        []

      false ->
        empty_slot_count = game.player_count - length(game.players)
        1..empty_slot_count
    end
  end

  defp other_players(game, current_player) do
    game.players
    |> Enum.filter(fn player -> player.id != current_player.id end)
    |> Enum.sort()
    |> Enum.with_index()
  end

  defp other_player_card_wrapper_style(_player, _index, _game) do
    "border-2"
  end

  defp grid_wrapper_classes(game) do
    "w-full grid grid-cols-2 grid-rows-#{grid_rows_num(game.player_count)} h-full justify-end"
  end

  defp grid_rows_num(player_count) do
    player_count / 2
    |> Float.floor()
    |> trunc()
  end
end
