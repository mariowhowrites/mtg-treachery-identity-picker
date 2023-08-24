defmodule MtgTreacheryWeb.GameLive.Panels.SettingsPanel do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer
  alias MtgTreachery.Multiplayer.Player

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="settings-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Name" />
        <%= if @current_player.identity != nil do %>
        <.input field={@form[:identity_id]} type="select" label="Identity" options={identity_options(@identities)}/>
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
      <%= if @current_player.creator and @game.status == :waiting and !Multiplayer.is_game_full(@game) do %>
        <section class="flex flex-col items-start gap-y-3 mb-6">
          <button
            phx-click="add_player"
            phx-target={@myself}
            class="px-4 py-2 bg-indigo-700 text-white rounded-lg shadow-sm hover:shadow-lg"
          >
            Add Player
          </button>
        </section>
      <% end %>
      <button
          phx-click="leave_game"
          class="px-4 mt-2 py-2 bg-red-700 text-white rounded-lg shadow-sm hover:shadow-lg"
        >
        Leave Game
      </button>
    </div>
    """
  end

  @impl true
  def update(%{current_player: current_player} = assigns, socket) do
    changeset = Player.settings_changeset(current_player, %{})
    identities = Multiplayer.list_identities()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:identities, identities)
      |> assign_player_form(changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      socket.assigns.current_player
      |> Player.settings_changeset(player_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_player_form(socket, changeset)}
  end

  def handle_event("save", %{"player" => player_params}, socket) do
    case Multiplayer.update_player_identity(socket.assigns.current_player, player_params) do
      {:ok, _game} ->
        {:noreply, socket |> push_patch(to: ~p"/game/identity")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_player_form(socket, changeset)}
    end
  end

  def handle_event("add_player", _params, socket) do
    Multiplayer.maybe_create_player(%{user_uuid: Ecto.UUID.generate()}, socket.assigns.game)

    {:noreply, socket}
  end

  defp identity_options(identities) do
    identities |> Enum.reduce([], fn (identity, acc) -> acc ++ ["#{identity.name}": identity.id] end)
  end

  defp assign_player_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
