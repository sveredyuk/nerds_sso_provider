defmodule Provider.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProviderWeb.Telemetry,
      Provider.Repo,
      {DNSCluster, query: Application.get_env(:provider, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Provider.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Provider.Finch},
      # Start a worker by calling: Provider.Worker.start_link(arg)
      # {Provider.Worker, arg},
      # Start to serve requests, typically the last entry
      ProviderWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Provider.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProviderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
