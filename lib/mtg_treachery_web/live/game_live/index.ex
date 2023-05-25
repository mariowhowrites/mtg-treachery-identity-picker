defmodule MtgTreacheryWeb.GameLive.Index do
  use MtgTreacheryWeb, :live_view

  alias MtgTreachery.Multiplayer
  alias MtgTreachery.Multiplayer.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :games, Multiplayer.list_games())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Game")
    |> assign(:game, Multiplayer.get_game!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game")
    |> assign(:game, %Game{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Games")
    |> assign(:game, nil)
  end

  @impl true
  def handle_info({MtgTreacheryWeb.GameLive.FormComponent, {:saved, game}}, socket) do
    {:noreply, stream_insert(socket, :games, game)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game = Multiplayer.get_game!(id)
    {:ok, _} = Multiplayer.delete_game(game)

    {:noreply, stream_delete(socket, :games, game)}
  end
end
