defmodule MtgTreacheryWeb.GameLive.Panels.PlayerPanel do
  use MtgTreacheryWeb, :live_component

  # def mount(socket) do
  #   IO.inspect(socket.assigns)
  #   if connected?(socket), do: maybe_redirect_to_lobby(socket), else: {:ok, socket}
  # end

  def update(assigns, socket) do
    if assigns.player == nil do
      send(self(), {:redirect_to_lobby})
    end

    {:ok, socket |> assign(assigns)}
  end

  defp maybe_redirect_to_lobby(socket) do
    case Map.has_key?(socket.assigns, :player) and socket.assigns.player != nil do
      true -> {:ok, socket}
      false -> {:ok, socket |> push_patch(to: ~p"/game/lobby")}
    end
  end

  def render(assigns) do
    ~H"""
    <section>
      <.link patch={~p"/game/lobby"}>Back to lobby</.link>
      <h1><%= if @player != nil, do: @player.name, else: "Loading..." %></h1>
      <h2>Identity</h2>
      <%= if @player != nil do %>
      <.identity_component identity={@player.identity} />
      <% end %>
    </section>
    """
  end
end
