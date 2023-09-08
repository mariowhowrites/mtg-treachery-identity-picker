defmodule MtgTreacheryWeb.GameLive.FormComponent do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer
  alias MtgTreachery.Multiplayer.Game

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>After creating a game, use the game code at the top of the lobby screen to invite other players.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="game-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:player_count]} type="number" label="Player Count" />
        <%!-- <.input field={@form[:rarity]} type="checkbox" label="Rarity" options={["Uncommon": "uncommon", "Rare": "rare", "Mythic Rare": "mythic"]} /> --%>
        <.checkgroup field={@form[:rarities]} label="Rarities" options={Game.rarity_options()} />
        <:actions>
          <.button phx-disable-with="Saving...">Create Game</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{game: game} = assigns, socket) do
    changeset = Multiplayer.change_game(game)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"game" => game_params}, socket) do
    changeset =
      socket.assigns.game
      |> Multiplayer.change_game(game_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"game" => game_params}, socket) do
    save_game(socket, socket.assigns.action, game_params, socket.assigns.user_uuid)
  end

  # defp save_game(socket, :edit, game_params) do
  #   case Multiplayer.update_game(socket.assigns.game, game_params) do
  #     {:ok, game} ->
  #       notify_parent({:saved, game})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Game updated successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  defp save_game(socket, :new, game_params, user_uuid) do
    case Multiplayer.create_game_with_player(game_params, user_uuid) do
      {:ok, game} ->
        notify_parent({:saved, game})

        {:noreply,
         socket
         |> push_navigate(to: ~p"/game")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
