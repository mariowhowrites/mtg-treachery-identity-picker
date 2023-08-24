defmodule MtgTreacheryWeb.ViewComponents do
  use Phoenix.Component

  def identity_component(assigns) do
    ~H"""
    <article phx-hook="IdentityCardContent" id={"identity_component_#{@identity.id}"}>
      <h2 class="text-lg font-semibold"><%= if @identity, do: @identity.name, else: "Loading..." %></h2>
      <%= for paragraph <- String.split(@identity.description, "\n") do %>
        <p class="mt-4"><%= paragraph %></p>
      <% end %>
    </article>
    """
  end
end
