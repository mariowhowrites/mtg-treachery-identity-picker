defmodule MtgTreacheryWeb.GameLive.Players.Show do
  use MtgTreacheryWeb, :live_component

  def render(assigns) do
    case assigns.player.id == assigns.current_player.id do
      true -> ~H"""
      <li>
        <%= if @is_editing_name do %>
          <input type="text"><button class="text-red-400 font-semibold" phx-click="stop_editing" phx-target={@myself}>X</button>
        <% else %>
          <%= @player.name %> (you)
          <button phx-click="start_editing" phx-target={@myself}>Edit</button>
        <% end %>
      </li>
      """
      false -> ~H"""
      <li><%= @player.name %></li>
      """
    end
  end

  def mount(socket) do
    {:ok, socket |> assign(:is_editing_name, false)}
  end

  def handle_event("start_editing", _params, socket) do
    {:noreply, socket |> assign(:is_editing_name, true)}
  end

  def handle_event("stop_editing", _params, socket) do
    {:noreply, socket |> assign(:is_editing_name, false)}
  end
end
