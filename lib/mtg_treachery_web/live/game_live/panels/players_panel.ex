defmodule MtgTreacheryWeb.GameLive.Panels.PlayersPanel do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:is_editing_name, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full">
      <section class="h-full w-4/5 mx-auto py-6 flex flex-col items-center gap-2 w-full">
        <h3 class="hidden">Other Players</h3>
        <ul class="w-full grid grid-cols-2 grid-rows-2 h-full justify-end">
          <%= for {player, index} <- other_players(@game, @current_player) do %>
            <li class={other_player_card_wrapper_style(player, index, @game)}>
              <div class="text-center">
                <%= player.name %>
              </div>
            </li>
          <% end %>
          <%= for _empty_slot <- empty_slots(@game) do %>
            <li class="w-1/2 h-20 border-2 text-center bg-gray-100 flex justify-center items-center">Empty slot</li>
          <% end %>
        </ul>
      </section>

      <%!-- controls -- this should move to settings page --%>
      <%= if @current_player.creator do %>
        <section class="flex flex-col items-start gap-y-3 mb-6">
          <button
            phx-click="add_player"
            phx-target={@myself}
            class="px-4 py-2 bg-indigo-700 text-white rounded-lg shadow-sm hover:shadow-lg"
          >
            Add Player
          </button>
        </section>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("add_player", _params, socket) do
    Multiplayer.maybe_create_player(%{user_uuid: Ecto.UUID.generate()}, socket.assigns.game)

    {:noreply, socket}
  end

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
    |> Enum.with_index()
  end

  defp other_player_card_wrapper_style(player, index, game) do
    "border-2"
  end
end
