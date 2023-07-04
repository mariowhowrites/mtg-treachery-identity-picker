defmodule MtgTreacheryWeb.GameLive.Players.Index do
  use MtgTreacheryWeb, :live_component
  alias MtgTreachery.Multiplayer

  def render(assigns) do
    ~H"""
    <section class="my-6 flex flex-col items-center gap-2">
      <ul class="flex flex-col gap-4">
      <%= for player <- @game.players do %>
        <li>
          <p>
            <%= player.name %> <%= if player.id == @current_player.id do %> (you)<% end %>
          </p>
          <%= if @game.status == :live do %>
          <p>
            <%= identity_text(player) %>
          </p>
          <% end %>
        </li>
      <% end %>
      <%= for _empty_slot <- empty_slots(@game) do %>
        <li>Empty slot</li>
      <% end %>
      </ul>
    </section>
    """
  end

  def empty_slots(game) do
    case Multiplayer.is_game_full(game) do
      true -> []
      false ->
        empty_slot_count = game.player_count - length(game.players)
        1..empty_slot_count
    end
  end

  def player_identity(player) do
    case player.identity == nil do
      true -> "No Identity"
      false -> "#{player.identity.name} - #{player.identity.role}"
    end
  end

  def identity_text(player) when player.status == :veiled do
    "Veiled"
  end

  def identity_text(player) when player.status == :unveiled do
    "#{player.identity.name} - #{player.identity.role}"
  end
end
