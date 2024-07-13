defmodule MtgTreacheryWeb.GameLive.Panels.LobbyPanel do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer
  alias MtgTreacheryWeb.Styling

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full">
      <section class="h-full w-4/5 mx-auto md:py-6 flex flex-col items-center gap-2 w-full">
        <h3 class="hidden">Other Players</h3>
        <ul class={grid_wrapper_classes(@game)}>
          <%= for {player, index} <- other_players(@game, @current_player) do %>
            <%!-- <li class={"#{Styling.role_background_color(player.identity.role)}"}> --%>
            <li class={other_player_wrapper_classes(@game, player, index)}>
              <div class="text-center h-full flex flex-col items-center justify-center">
                <.link navigate={~p"/player/#{player.id}"} class="underline">
                  <span><%= player.name %></span>
                </.link>

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

  defp other_player_wrapper_classes(game, player, index) do
    ["mb-1"]
    |> maybe_add_right_border(index)
    |> add_background_color(player)
  end

  defp maybe_add_right_border(class_list, index) do
    if rem(index, 2) == 0, do: class_list ++ ["mr-1"], else: class_list
  end

  defp add_background_color(class_list, player) do
    [
      class_list,
      case player.status do
        :veiled -> "bg-gray-700"
        _ -> Styling.role_background_color(player.identity.role)
      end
    ]
  end

  defp other_slots(game) do
    List.duplicate(nil, game.player_count - 1)
  end

  defp grid_wrapper_classes(game) do
    "w-full grid grid-cols-2 grid-rows-#{grid_rows_num(game.player_count)} h-full justify-end"
  end

  defp grid_rows_num(player_count) do
    (player_count / 2)
    |> Float.floor()
    |> trunc()
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
      <span class="font-semibold"><%= @player.identity.role %></span>
      <span><%= @player.identity.name %></span>
    </div>
    """
  end
end
