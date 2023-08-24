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
    <section class="flex flex-col gap-12" id="identity-index">
      <%= for identity <- @identities do %>
        <.identity_component identity={identity} />
      <% end %>
    </section>
    """
  end
end
