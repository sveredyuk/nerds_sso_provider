defmodule Provider.Repo do
  use Ecto.Repo,
    otp_app: :provider,
    adapter: Ecto.Adapters.Postgres
end
