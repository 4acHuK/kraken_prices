defmodule KrakenPrices.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KrakenPricesWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:kraken_prices, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: KrakenPrices.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: KrakenPrices.Finch},
      # Start a worker by calling: KrakenPrices.Worker.start_link(arg)
      # {KrakenPrices.Worker, arg},
      # Start to serve requests, typically the last entry
      KrakenPricesWeb.Endpoint,
      KrakenPrices.Services.PriceSocketService
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KrakenPrices.Supervisor]
    Supervisor.start_link(children, opts)
  end
#
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KrakenPricesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
