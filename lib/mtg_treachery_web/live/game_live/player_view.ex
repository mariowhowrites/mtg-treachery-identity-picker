defmodule MtgTreacheryWeb.GameLive.PlayerView do
  use MtgTreacheryWeb, :live_view

  alias MtgTreachery.Multiplayer
  alias MtgTreachery.Multiplayer.Player
  alias MtgTreacheryWeb.IdentityLive.IdentityCard

  @impl true
  def mount(%{"id" => id}, session, socket) do
    selected_player = Multiplayer.get_player_by_id!(id)
    game = selected_player.game
    current_player = get_current_player_from_game(game, Map.get(session, "user_uuid"))

    if connected?(socket) do
      Multiplayer.Game.subscribe_game(game.id)
    end

    {
      :ok,
      socket
      |> assign(:selected_player, selected_player)
      |> assign(:current_player, current_player)
      |> assign(:is_card_flipped, selected_player.status == :unveiled)
      |> assign(:is_peeking, false)
      |> assign(:game, game)
    }
  end

  def handle_params(unsigned_params, uri, socket) do
    {:noreply, socket}
  end

  defp get_current_player_from_game(game, user_uuid),
    do: Enum.find(game.players, fn player -> player.user_uuid == user_uuid end)

  @impl true
  def handle_event("add_player", _params, socket) do
    Multiplayer.maybe_create_player(%{user_uuid: Ecto.UUID.generate()}, socket.assigns.game)

    {:noreply, socket}
  end

  def handle_event("peek", _unsigned_params, socket) do
    is_peeking = !socket.assigns.is_peeking

    {
      :noreply,
      socket
      |> assign(:is_peeking, is_peeking)
      |> assign(:is_card_flipped, determine_flip_status(socket, is_peeking))
    }
  end

  def handle_event("attempt_unveil", _unsigned_params, socket) do
    {
      :noreply,
      socket
      |> push_patch(to: ~p"/player/#{socket.assigns.selected_player.id}/unveil")
    }
  end

  def handle_event("unveil", _params, socket) do
    Multiplayer.update_player(socket.assigns.current_player, %{status: :unveiled})

    {
      :noreply,
      socket
      |> assign(:is_card_flipped, true)
      |> put_flash(:info, "You have unveiled!")
      |> push_patch(to: ~p"/player/#{socket.assigns.selected_player.id}")
    }
  end

  def handle_event("veil", _params, socket) do
    Multiplayer.update_player(socket.assigns.current_player, %{status: :veiled})

    {:noreply, socket |> assign(:is_card_flipped, false)}
  end

  def handle_event("force_unveil", _params, socket) when socket.assigns.current_player.creator do
    Multiplayer.update_player(socket.assigns.selected_player, %{status: :unveiled})

    {
      :noreply,
      socket
      |> assign(:is_card_flipped, true)
      |> put_flash(:info, "Player forced unveiled!")
    }
  end

  def handle_event("force_unveil", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("force_peek", _unsigned_params, socket) when socket.assigns.current_player.creator do
    is_peeking = !socket.assigns.is_peeking

    {
      :noreply,
      socket
      |> assign(:is_peeking, is_peeking)
      |> assign(:is_card_flipped, determine_flip_status(socket, is_peeking))
    }
  end

  def handle_event("force_peek", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("leave_game", _params, socket) do
    Multiplayer.update_player(socket.assigns.current_player, %{status: :inactive})

    {
      :noreply,
      socket
      |> put_flash(:info, "Game left successfully")
      |> push_navigate(to: ~p"/")
    }
  end

  @impl true
  def handle_info({:game, game_id}, socket) do
    game = Multiplayer.get_game!(game_id)
    current_player = get_current_player_from_game(game, socket.assigns.current_player.user_uuid)

    selected_player =
      Enum.find(game.players, fn player -> player.id == socket.assigns.selected_player.id end)

    {
      :noreply,
      socket
      |> assign(:game, game)
      |> assign(:current_player, current_player)
      |> assign(:selected_player, selected_player)
    }
  end

  defp flip_card(socket) do
    assign(socket, :is_card_flipped, !socket.assigns.is_card_flipped)
  end

  defp determine_flip_status(socket, is_peeking) do
    is_peeking or socket.assigns.selected_player.status == :unveiled
  end
end
