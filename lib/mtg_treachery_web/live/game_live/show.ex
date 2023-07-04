defmodule MtgTreacheryWeb.GameLive.Show do
  use MtgTreacheryWeb, :live_view

  alias MtgTreachery.Multiplayer
  alias MtgTreacheryWeb.GameLive.IdentityCard

  @impl true
  def mount(_params, session, socket) do
    user_uuid = Map.get(session, "user_uuid")
    game = Multiplayer.get_game_by_user_uuid(user_uuid)
    player = get_current_player_from_game(game, user_uuid)

    case connected?(socket) do
      false ->
        :ok

      true ->
        Multiplayer.Game.subscribe_game(game.id)
    end

    {
      :ok,
      socket
      |> assign(:game, game)
      |> assign(:current_player, player)
      |> assign(:user_uuid, user_uuid)
      |> assign(:is_card_flipped, player.status == :unveiled)
    }
  end

  @impl true
  def handle_info({:game, game_id}, socket) do
    game = Multiplayer.get_game!(game_id)
    player = get_current_player_from_game(game, socket.assigns.user_uuid)

    {
      :noreply,
      socket
      |> assign(:game, game)
      |> assign(:current_player, player)
    }
  end

  def handle_event("unveil", _params, socket) do
    Multiplayer.update_player(socket.assigns.current_player, %{status: :unveiled})

    {:noreply, socket |> flip_card()}
  end


  @impl true
  def handle_params(_params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
    }
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    case(socket.assigns.current_player.creator) do
      true ->
        Multiplayer.start_game(socket.assigns.game)
        {:noreply, socket |> push_patch(to: ~p"/game/identity")}
      false -> {:noreply, socket}
    end
  end

  def handle_event("add_player", _params, socket) do
    Multiplayer.maybe_create_player(%{user_uuid: Ecto.UUID.generate()}, socket.assigns.game)

    {:noreply, socket}
  end

  def handle_event("copy_game_code", _params, socket) do
    {
      :noreply,
      socket
      |> put_flash(:info, "Copied!")
    }
  end

  def handle_event("peek", _params, socket) do
    JS.dispatch("replace_mana_values", to: "#identity-card-content")

    {
      :noreply,
      socket
      |> flip_card()
    }
  end

  defp page_title(:show), do: "New Game"
  defp page_title(:identity), do: "Your Identity"
  defp page_title(:players), do: "All Players"
  defp page_title(:settings), do: "Game Settings"

  defp get_current_player_from_game(game, user_uuid), do: Enum.find(game.players, fn player -> player.user_uuid == user_uuid end)

  defp game_subtitle(game) do
    if Multiplayer.is_game_full(game) do
      "In Game"
    else
      "Pre-Game Lobby - Game Code #{game.game_code}"
    end
  end

  defp flip_card(socket) do
    assign(socket, :is_card_flipped, !socket.assigns.is_card_flipped)
  end
end
