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
    name_changeset = Player.name_changeset(selected_player, %{})

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
      |> assign(:is_editing_name, false)
      |> assign(:game, game)
      |> assign_player_form(name_changeset)
    }
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

  def handle_event("unveil", _params, socket) do
    Multiplayer.update_player(socket.assigns.current_player, %{status: :unveiled})

    {:noreply, socket |> flip_card()}
  end

  def handle_event("start_editing_name", unsigned_params, socket) do
    {:noreply, socket |> assign(:is_editing_name, true)}
  end

  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      socket.assigns.selected_player
      |> Player.settings_changeset(player_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_player_form(socket, changeset)}
  end

  def handle_event("save", %{"player" => player_params}, socket) do
    case Multiplayer.update_player_identity(socket.assigns.selected_player, player_params) do
      {:ok, _game} ->
        {
          :noreply,
          socket
          |> assign(:is_editing_name, false)
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_player_form(socket, changeset)}
    end
  end

  def handle_info({:game, game_id}, socket) do
    game = Multiplayer.get_game!(game_id)
    player = get_current_player_from_game(game, socket.assigns.selected_player.user_uuid)

    {
      :noreply,
      socket
      |> assign(:game, game)
      |> assign(:selected_player, player)
    }
  end

  defp flip_card(socket) do
    assign(socket, :is_card_flipped, !socket.assigns.is_card_flipped)
  end

  defp determine_flip_status(socket, is_peeking) do
    is_peeking or socket.assigns.selected_player.status == :unveiled
  end

  defp name_component(assigns) when assigns.current_player.id != assigns.selected_player.id do
    ~H"""
    <h1 class="font-bold text-2xl"><%= @selected_player.name %></h1>
    """
  end

  defp name_component(assigns) when assigns.current_player.id == assigns.selected_player.id and assigns.is_editing_name == false do
    ~H"""
    <span class="flex gap-2">
      <h1 class="font-bold text-2xl"><%= @selected_player.name %></h1>
      <button phx-click="start_editing_name"><.icon name="hero-pencil-square"/></button>
    </span>
    """
  end

  defp name_component(assigns) when assigns.is_editing_name == true do
    ~H"""
      <.simple_form
        for={@form}
        id="settings-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    """
  end

  defp assign_player_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
