defmodule MtgTreacheryWeb.GameLive.Panels.PlayerPanel do
  alias MtgTreachery.Multiplayer.Player
  use MtgTreacheryWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(:is_editing_name, false)}
  end

  def update(%{current_player: current_player} = assigns, socket) do
    changeset = Player.name_changeset(current_player, %{})

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end


  def render(assigns) do
    ~H"""
    <section class="mx-2">
      <.link patch={~p"/game/lobby"}>Back to lobby</.link>
      <h2>Player</h2>
      <%= player_name_panel(assigns) %>
      <%= if @player.identity != nil do %>
      <h2>Identity</h2>
      <.identity_component identity={@player.identity} />
      <% end %>
    </section>
    """
  end

  defp player_name_panel(assigns) when assigns.is_editing_name == false do
    ~H"""
    <span>
      <h3><%= if @player != nil, do: @player.name, else: "Loading..." %></h3>

      <%= if @player.id == @current_player.id do %>
      <button phx-click="start_editing_name" phx-target={@myself}>
        Edit Name
      </button>
      <% end %>
    </span>
    """
  end

  def handle_event("start_editing_name", _params, socket) do
    {:noreply, socket |> assign(:is_editing_name, true)}
  end

  defp player_name_panel(assigns) when assigns.is_editing_name == true do
    ~H"""
    <.simple_form>

    </.simple_form>
    """
  end
end
