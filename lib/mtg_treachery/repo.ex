defmodule MtgTreachery.Repo do
  use Ecto.Repo,
    otp_app: :mtg_treachery,
    adapter: Ecto.Adapters.Postgres
end
