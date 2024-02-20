defmodule BodyArchitect.Repo do
  use Ecto.Repo,
    otp_app: :body_architect,
    adapter: Ecto.Adapters.Postgres
end
