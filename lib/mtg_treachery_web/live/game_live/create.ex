defmodule MtgTreacheryWeb.GameLive.Create do
  use MtgTreacheryWeb, :live_view

  alias MtgTreachery.Multiplayer.Game

  def mount(_params, session, socket) do
    {
      :ok,
      assign(socket, :user_uuid, Map.get(session, "user_uuid"))
      |> assign(:game, %Game{})
      |> assign(:page_title, "Create a game")
    }
  end

  def handle_info({MtgTreacheryWeb.GameLive.FormComponent, {:saved, _game}, socket}) do
    {:noreply, push_navigate(socket, to: ~p"/game")}
  end
end
