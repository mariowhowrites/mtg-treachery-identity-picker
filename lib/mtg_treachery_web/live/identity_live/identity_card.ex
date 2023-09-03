defmodule MtgTreacheryWeb.IdentityLive.IdentityCard do
  alias MtgTreachery.Multiplayer
  use MtgTreacheryWeb, :html

  def show(assigns) do
    ~H"""
    <div
      id="identity-card"
      phx-hook="IdentityCardContent"
      class="w-72 h-[27rem] text-black rounded-2xl shadow-xl flex flex-col justify-center items-center transition-transform font-serif"
      style={identity_card_style(@is_card_flipped)}
    >
      <div
        id="identity-card-back"
        class="absolute rounded-xl top-0 left-0 h-full w-full flex items-center justify-center bg-back shadow-lg"
        style="transform: rotateY(0deg); backface-visibility: hidden;"
      >
        <%= if @selected_player.id == @current_player.id do %>
          <button
            class="px-4 py-2 bg-indigo-700 text-white rounded-lg shadow-sm hover:shadow-lg"
            phx-click="peek"
            phx-target="#identity-panel"
          >
            Peek
          </button>
        <% end %>
      </div>
      <div
        id="identity-card-front"
        class={identity_card_front_classes(@selected_player)}
        style="transform: rotateY(180deg); backface-visibility: hidden;"
      >
        <div
          id="identity-card-content"
          class="h-full flex flex-col items-center justify-between"
        >
          <section id="identity-header" class="text-center bg-stone-100 w-full py-2 border border-2 px-4 rounded-t-xl">
            <h3 class="text-lg font-bold text-zinc-800"><%= @selected_player.identity.name %></h3>
          </section>
          <div class="flex flex-col items-center bg-stone-100 text-zinc-800 mx-4 mb-4">
            <div class="border-b-2 border-stone-200 w-full text-center py-1 font-semibold">
              <%= @selected_player.identity.role %>
            </div>
            <div class="px-2 rounded-sm mb-4 text-sm pt-2">
              <div>Unveil cost: <%= @selected_player.identity.unveil_cost %></div>
              <%= for paragraph <- String.split(@selected_player.identity.description, "\n") do %>
                <p class="mt-1"><%= paragraph %></p>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def identity_card_style(is_card_flipped) when is_card_flipped == true do
    "transform-style: preserve-3d; transform: rotateY(-180deg);"
  end

  def identity_card_style(is_card_flipped) when is_card_flipped == false do
    "transform-style: preserve-3d;"
  end

  defp identity_card_front_classes(selected_player) do
    [
      "absolute top-0 left-0 h-full rounded-xl",
      role_background(selected_player.identity.role)
    ]
  end

  defp role_background(role) do
    case role do
      "Leader" -> "bg-leader"
      "Guardian" -> "bg-guardian"
      "Assassin" -> "bg-assassin"
      "Traitor" -> "bg-traitor"
    end
  end
end
