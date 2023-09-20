defmodule MtgTreachery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Telemetry supervisor
      MtgTreacheryWeb.Telemetry,
      # Start the Ecto repository
      MtgTreachery.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: MtgTreachery.PubSub},
      # Start Finch
      {Finch, name: MtgTreachery.Finch},
      # Start life server cache
      MtgTreachery.LifeTotals.Cache,
      # Attach life total servers to any existing games
      MtgTreachery.Tasks.LifeServerSetup,
      # Check for old games and shutdown related life total servers
      MtgTreachery.CronJobs.CleanupLifeTotalServers,
      # Start the Endpoint (http/https)
      MtgTreacheryWeb.Endpoint,
      # Start a worker by calling: MtgTreachery.Worker.start_link(arg)
      # {MtgTreachery.Worker, arg}

      {Cluster.Supervisor, [topologies, [name: MtgTreachery.ClsuterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MtgTreachery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MtgTreacheryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
