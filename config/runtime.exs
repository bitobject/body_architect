import Config

maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

if System.get_env("PHX_SERVER") do
  config :body_architect, BodyArchitectWeb.Endpoint, server: true
end

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

body_architect_port =
  "WEB_PORT"
  |> System.fetch_env!()
  |> String.to_integer()

pool_size =
  "POOL_SIZE"
  |> System.fetch_env!()
  |> String.to_integer()

default_locale = System.fetch_env!("DEFAULT_LOCALE")

config :body_architect, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")
config :body_architect, BodyArchitectWeb.Gettext, default_locale: default_locale

config :body_architect, BodyArchitectWeb.Endpoint,
  url: [host: System.fetch_env!("WEB"), port: body_architect_port],
  http: [ip: {0, 0, 0, 0}, port: body_architect_port],
  secret_key_base: secret_key_base

if config_env() != :test do
  config :body_architect, BodyArchitect.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: System.fetch_env!("POSTGRES_USER"),
    password: System.fetch_env!("POSTGRES_PASSWORD"),
    database: System.fetch_env!("POSTGRES_DB"),
    hostname: System.fetch_env!("PG_HOST"),
    port: System.fetch_env!("PG_PORT"),
    socket_options: maybe_ipv6,
    pool_size: pool_size
end
