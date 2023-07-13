defmodule MtgTreacheryWeb.GameLive.NewPlayerForm do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <p>Player Settings</p>
        <:subtitle>Customize your player before joining the lobby</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="player-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="number" label="In-Game Name" />
      </.simple_form>
    </div>
    """
  end

  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      socket.assigns.player
      |> Multiplayer.change_player(player_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
