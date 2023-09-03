defmodule MtgTreacheryWeb.GameLive.Panels.LobbyPanel do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full">
      <section class="h-full w-4/5 mx-auto md:py-6 flex flex-col items-center gap-2 w-full">
        <h3 class="hidden">Other Players</h3>
        <ul class={grid_wrapper_classes(@game)}>
          <%= for {player, index} <- other_players(@game, @current_player) do %>
            <li class={other_player_card_wrapper_style(player, index, @game)}>
              <div class="text-center h-full flex flex-col items-center justify-center">
                <span><%= player.name %></span>
                <%!-- testing button below, remove in prod --%>
                <%!-- <button phx-click="unveil_player" phx-value-player={player.id}>Toggle Veil</button> --%>
                <%= identity_text(player) %>
                <%= if @game.status != :waiting do %>
                  <span><%= @life_totals[player.id] %></span>
                <% end %>
              </div>
            </li>
          <% end %>
          <%= for _empty_slot <- empty_slots(@game) do %>
            <li class="text-center bg-gray-100 mr-1 mb-1 flex justify-center items-center text-zinc-800">
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

  defp other_slots(game) do
    List.duplicate(nil, game.player_count - 1)
  end

  # # leader
  # defp other_player_card_wrapper_style(player, index, game) when index === 0 do
  #   "bg-orange-700"
  # end

  # # guardian
  # defp other_player_card_wrapper_style(player, index, game) when index === 1 do
  #   "bg-teal-700"
  # end

  # # assassin
  # defp other_player_card_wrapper_style(player, index, game) when index === 2 do
  #   "bg-red-700"
  # end

  # # traitor
  # defp other_player_card_wrapper_style(player, index, game) when index === 3 do
  #   "bg-violet-700"
  # end

  defp other_player_card_wrapper_style(player, index, game) do
    [
      "transition-colors",
      case player.identity do
        nil -> "bg-gray-700"
        _ -> ["bg-gray-700", player_color(player)]
      end
    ]
  end

  defp player_color(player) do
    case player.status do
      :veiled -> "bg-gray-700"
      _ -> role_color(player.identity.role)
    end
  end

  defp grid_wrapper_classes(game) do
    "w-full grid grid-cols-2 grid-rows-#{grid_rows_num(game.player_count)} h-full justify-end"
  end

  defp grid_rows_num(player_count) do
    (player_count / 2)
    |> Float.floor()
    |> trunc()
  end

  defp role_color(role) do
    case role do
      "Leader" -> "border-amber-400 border-4"
      "Guardian" -> "border-cyan-600 border-4"
      "Assassin" -> "border-rose-600 border-4"
      "Traitor" -> "border-violet-700 border-4"
    end
  end

  def identity_text(player) when player.identity == nil do
    nil
  end

  def identity_text(player) when player.identity != nil and player.status == :veiled do
    "Veiled"
  end

  def identity_text(player) when player.identity != nil and player.status != :veiled do
    assigns = %{player: player}

    ~H"""
      <div class="flex flex-col">
        <span><%= @player.identity.role %></span>
        <button phx-click="view_player" class="underline" phx-value-player-id={@player.id}>
          <%= @player.identity.name %>
        </button>
      </div>
    """
  end

  # defp identity_text(player) do
  #   assigns = %{player: player}

  #   ~H"""
  #     <span><%= player.status %></span>
  #       <%!-- test button, remove for prod --%>
  #     <%= if player.identity != nil and player.status != :veiled do %>
  #       <button phx-click="view_player" class="underline" phx-value-player-id={player.id}>
  #         <%= player.identity.role %> - <%= player.identity.name %>
  #       </button>
  #   """
  # end
end
