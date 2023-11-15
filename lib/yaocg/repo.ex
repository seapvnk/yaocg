defmodule Yaocg.Repo do
  use Ecto.Repo,
    otp_app: :yaocg,
    adapter: Ecto.Adapters.Postgres
end
