defmodule BodyArchitect.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BodyArchitectWeb.Telemetry,
      BodyArchitect.Repo,
      {DNSCluster, query: Application.get_env(:body_architect, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BodyArchitect.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BodyArchitect.Finch},
      # Start a worker by calling: BodyArchitect.Worker.start_link(arg)
      # {BodyArchitect.Worker, arg},
      # Start to serve requests, typically the last entry
      BodyArchitectWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BodyArchitect.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BodyArchitectWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
