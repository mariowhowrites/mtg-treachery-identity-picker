defmodule MtgTreacheryWeb.IdentityLive.Index do
  use MtgTreacheryWeb, :live_view

  alias MtgTreachery.Multiplayer

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:identities, Multiplayer.list_identities())
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="flex flex-col gap-12" phx-hook="IdentityCardContent" id="identity-index">
      <%= for identity <- @identities do %>
        <article>
          <h2 class="text-lg font-semibold"><%= identity.name %></h2>
          <%= for paragraph <- String.split(identity.description, "\n") do %>
            <p class="mt-4"><%= paragraph %></p>
          <% end %>
        </article>
      <% end %>
    </section>
    """
  end
end
