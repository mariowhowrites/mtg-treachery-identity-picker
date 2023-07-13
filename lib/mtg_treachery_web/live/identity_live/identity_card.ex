defmodule MtgTreacheryWeb.IdentityLive.IdentityCard do
  use MtgTreacheryWeb, :html
  def show(assigns) do
    ~H"""
    <div
      id="identity-card"
      phx-hook="IdentityCardContent"
      class="w-72 h-96 bg-orange-300 rounded-2xl shadow-xl flex flex-col justify-center items-center transition-transform font-serif"
      style={identity_card_style(@is_card_flipped)}
    >
      <div
        id="identity-card-front"
        class="absolute top-0 left-0 h-full w-full flex items-center justify-center"
        style="transform: rotateY(0deg); backface-visibility: hidden;"
      >
        <button
          class="px-4 py-2 bg-indigo-700 text-white rounded-lg shadow-sm hover:shadow-lg"
          phx-click="unveil"
          phx-target="#identity-panel"
        >
          Unveil
        </button>
      </div>
      <div
        id="identity-card-back"
        class="absolute top-0 left-0 h-full"
        style="transform: rotateY(180deg); backface-visibility: hidden;"
      >
        <div id="identity-card-content" class="h-full flex flex-col items-center justify-between">
          <section class="text-center mt-4">
            <h3 class="text-lg font-semibold"><%= @current_player.identity.name %></h3>
            <div><%= @current_player.identity.role %></div>
            <div>Unveil cost: <%= @current_player.identity.unveil_cost %></div>
            <%!-- <div>Unveil cost: <span class="bg-gray-100 rounded-full px-2 py-1 text-black">4</span></div> --%>
          </section>
          <div class="mx-4 px-2 rounded-sm mb-4 bg-stone-100 text-sm">
            <%= for paragraph <- String.split(@current_player.identity.description, "\n") do %>
              <p class="mt-1"><%= paragraph %></p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <button class="text-gray-700 text-xs" phx-click="peek" phx-target="#identity-panel">Peek (look at card without unveiling)</button>
    """
  end

  def identity_card_style(is_card_flipped) when is_card_flipped == true do
    "transform-style: preserve-3d; transform: rotateY(-180deg);"
  end

  def identity_card_style(is_card_flipped) when is_card_flipped == false do
    "transform-style: preserve-3d;"
  end
end
