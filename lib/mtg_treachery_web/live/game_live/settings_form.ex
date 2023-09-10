defmodule MtgTreacheryWeb.GameLive.SettingsForm do
  use MtgTreacheryWeb, :live_component

  alias MtgTreachery.Multiplayer
  alias MtgTreachery.Multiplayer.Player

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
        <%= if @player.identity != nil and Ecto.assoc_loaded?(@player.identity) do %>
          <.input
            field={@form[:identity_id]}
            type="select"
            label="Identity"
            options={identity_options(@identities)}
          />
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{player: player} = assigns, socket) do
    changeset = Player.settings_changeset(player, %{})
    identities = Multiplayer.list_identities()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:identities, identities)
      |> assign_player_form(changeset)
    }
  end

  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      socket.assigns.player
      |> Player.settings_changeset(player_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_player_form(socket, changeset)}
  end

  def handle_event("save", %{"player" => player_params}, socket) do
    case Multiplayer.update_player_identity(socket.assigns.player, player_params) do
      {:ok, game} ->
        {:noreply, socket |> push_patch(to: ~p"/player/#{socket.assigns.player.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_player_form(socket, changeset)}
    end
  end

  defp identity_options(identities) do
    identities
    |> Enum.sort_by(&{&1.role, &1.rarity})
    |> Enum.reduce([], &create_identity_list/2)
  end

  defp create_identity_list(identity, list) do
    list ++ ["#{identity.name} - #{identity.role} #{identity.rarity}": identity.id]
  end

  defp assign_player_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
