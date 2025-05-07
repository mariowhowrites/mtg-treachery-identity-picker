defmodule MtgTreacheryWeb.GameLive.Panels.IdentityPanel do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer
  alias MtgTreacheryWeb.IdentityLive.IdentityCard

  def render(assigns) do
    ~H"""
    <div id="identity-panel" class="flex flex-col items-center gap-y-4 w-full">
      <%= if @current_player.identity != nil do %>
        <IdentityCard.show is_card_flipped={@is_card_flipped} current_player={@current_player} />
      <% else %>
        <h2>No identity yet! Start a game first</h2>
      <% end %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(:is_card_flipped, false) |> assign(:is_peeking, false)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:is_card_flipped, determine_flip_status(assigns))}
  end

  def handle_event("peek", _unsigned_params, socket) do
    {
      :noreply,
      socket
      |> assign(:is_peeking, !socket.assigns.is_peeking)
      |> assign(:is_card_flipped, determine_flip_status(socket.assigns))
    }
  end

  def handle_event("unveil", _params, socket) do
    Multiplayer.update_player(socket.assigns.current_player, %{status: :unveiled})

    {:noreply, socket |> flip_card()}
  end

  defp flip_card(socket) do
    assign(socket, :is_card_flipped, !socket.assigns.is_card_flipped)
  end

  defp determine_flip_status(assigns) do
    case Map.has_key?(assigns, :is_peeking) do
      true -> assigns.is_peeking
      false -> assigns.current_player.status == :unveiled
    end
  end
end
