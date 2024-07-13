defmodule MtgTreacheryWeb.GameLive.Show do
  use MtgTreacheryWeb, :live_view

  alias MtgTreacheryWeb.Styling
  alias MtgTreachery.Multiplayer
  alias MtgTreacheryWeb.GameLive.Panels.{LobbyPanel, IdentityPanel, SettingsPanel, PlayerPanel}
  alias MtgTreachery.LifeTotals

  @impl true
  def mount(_params, session, socket) do
    user_uuid = Map.get(session, "user_uuid")
    game = Multiplayer.get_game_by_user_uuid(user_uuid)

    if game == nil do
      {:ok, socket |> push_navigate(to: ~p"/")}
    else
      mount_with_game(user_uuid, game, socket)
    end
  end

  defp mount_with_game(user_uuid, game, socket) do
    player = get_current_player_from_game(game, user_uuid)
    life_totals = %{}

    if connected?(socket) do
      Multiplayer.Game.subscribe_game(game.id)
      Multiplayer.Game.subscribe_life_totals(game.id)
    end

    {
      :ok,
      socket
      |> assign(:game, game)
      |> assign(:current_player, player)
      |> assign(:user_uuid, user_uuid)
      |> assign(:life_totals, life_totals)
    }
  end

  @impl true
  def handle_params(_params, _, socket) do
    life_totals = LifeTotals.get_life_totals_by_game_id(socket.assigns.game.id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:life_totals, life_totals)}
  end

  @impl true
  def handle_event("copy_game_code", _params, socket) do
    {
      :noreply,
      socket
      |> push_event("copy_game_code", %{
        url: url(~p"/join/#{socket.assigns.game.game_code}")
      })
      |> put_flash(:info, "Invite URL Copied!")
    }
  end

  def handle_event("start_game", _params, socket) do
    case(socket.assigns.current_player.creator) do
      true ->
        Multiplayer.start_game(socket.assigns.game)
        {:noreply, socket}

      false ->
        {:noreply, socket}
    end
  end

  def handle_event("view_player", %{"player-id" => player_id}, socket) do
    {
      :noreply,
      socket
      |> push_navigate(to: ~p"/player/#{player_id}")
    }
  end

  def handle_event("unveil_player", %{"player" => player_id}, socket) do
    player = Multiplayer.get_player_by_id!(player_id)

    Multiplayer.update_player(player, %{
      status: if(player.status == :veiled, do: :unveiled, else: :veiled)
    })

    {:noreply, socket |> assign(:selected_player, player) |> push_patch(to: ~p"/game/lobby")}
  end

  def handle_event("gain_life", %{"player-id" => player_id}, socket) do
    LifeTotals.gain_life(socket.assigns.game.id, player_id)
    {:noreply, socket}
  end

  def handle_event("lose_life", %{"player-id" => player_id}, socket) do
    LifeTotals.lose_life(socket.assigns.game.id, player_id)
    {:noreply, socket}
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

  def handle_info({:game_start}, socket) do
    {:noreply, socket |> push_patch(to: ~p"/game/identity")}
  end

  def handle_info({:redirect_to_lobby}, socket) do
    {:noreply, socket |> push_patch(to: ~p"/game/lobby")}
  end

  def handle_info({:life_totals, life_totals}, socket) do
    {:noreply, socket |> assign(:life_totals, life_totals)}
  end

  defp page_title(:show), do: "New Game"
  defp page_title(:identity), do: "Your Identity"
  defp page_title(:lobby), do: "Lobby"
  defp page_title(:settings), do: "Settings"
  defp page_title(:player), do: "Player Details"

  defp get_current_player_from_game(game, user_uuid),
    do: Enum.find(game.players, fn player -> player.user_uuid == user_uuid end)

  defp should_show_start_game_button(game, current_player) do
    Multiplayer.is_game_full(game) and current_player.creator and game.status == :waiting
  end

  def should_show_life_controls(game, _current_player) do
    game.status == :live
  end
end
