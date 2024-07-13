defmodule MtgTreacheryWeb.GameLive.Join do
  alias MtgTreachery.Multiplayer
  use MtgTreacheryWeb, :live_view

  def render(assigns) do
    ~H"""
    <section>
      <.header>
      Join a Game
      </.header>
      <.form phx-change="validate" phx-submit="attempt_join" for={@form}>
        <.input field={@form[:game_code]} label="Game Code"/>
        <.input field={@form[:name]} label="In-Game Name"/>
        <.button class="mt-2">Join Game</.button>
      </.form>
    </section>
    """
  end

  def mount(%{"game_code" => game_code}, session, socket) do
    user_uuid = Map.get(session, "user_uuid")

    {
      :ok,
      socket
      |> assign(:form, to_form(%{"game_code" => game_code, "name" => "New Player"}))
      |> assign(:user_uuid, user_uuid)
    }
  end

  def handle_event("validate", params, socket) do
    {
      :noreply,
      socket
      |> assign(:form, to_form(params))
    }
  end

  def handle_event("attempt_join", %{"game_code" => game_code, "name" => name}, socket) do
    case Multiplayer.maybe_join_game(%{game_code: game_code, user_uuid: socket.assigns.user_uuid, name: name}) do
      {:ok, _player} -> {:noreply, socket |> push_navigate(to: ~p"/game/lobby")}
      _ -> {:noreply, socket}
    end
  end
end
