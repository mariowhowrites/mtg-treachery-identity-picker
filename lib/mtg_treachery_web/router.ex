defmodule MtgTreacheryWeb.Router do
  use MtgTreacheryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MtgTreacheryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user_uuid
  end

  def fetch_current_user_uuid(conn, _) do
    if user_uuid = get_session(conn, :user_uuid) do
      assign(conn, :user_uuid, user_uuid)
    else
      new_uuid = Ecto.UUID.generate()

      conn |> assign(:user_uuid, new_uuid) |> put_session(:user_uuid, new_uuid)
    end
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MtgTreacheryWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/game", GameLive.Show, :lobby, container: {:div, class: "h-full"}
    live "/game/identity", GameLive.Show, :identity, container: {:div, class: "h-full"}
    live "/game/lobby", GameLive.Show, :lobby, container: {:div, class: "h-full"}
    live "/game/settings", GameLive.Show, :settings, container: {:div, class: "h-full"}
    live "/game/player", GameLive.Show, :player, container: {:div, class: "h-full"}

    live "/player/:id", GameLive.PlayerView, :player, container: {:div, class: "h-full"}
    live "/player/:id/settings", GameLive.PlayerView, :settings, container: {:div, class: "h-full"}


    live "/create", GameLive.Create, :new, container: {:div, class: "h-full"}

    live "/join", GameLive.Join, :join, container: {:div, class: "h-full"}

    live "/identities", IdentityLive.Index, :index, container: {:div, class: "h-full"}

    # live "/games", GameLive.Index, :index
    # live "/games/new", GameLive.Index, :new
    # live "/games/:id/edit", GameLive.Index, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", MtgTreacheryWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mtg_treachery, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MtgTreacheryWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
