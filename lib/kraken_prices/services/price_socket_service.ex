defmodule KrakenPrices.Services.PriceSocketService do
  @moduledoc """
    Subscribes to Kraken's Websocket API, gets trading pair prices and broadcasts them to KrakenPricesWeb.PricesLive LiveView
  """

  use WebSockex

  def start_link(opts \\ []) do
    client = Keyword.get(opts, :websocket_client, WebSockex)
    client.start_link("wss://ws.kraken.com/v2", __MODULE__, nil)
  end

  @impl true
  def handle_connect(_conn, state) do
    pairs = KrakenPrices.Services.GetTradingPairsService.get_trading_pairs()
    pair_batches = Enum.chunk_every(pairs, 50)

    Enum.each(pair_batches, fn pair_batch ->
      send(self(), {:subscribe, pair_batch})
    end)

    {:ok, state}
  end

  @impl true
  def handle_frame({:text, data}, state) do
    case Jason.decode!(data) do
      %{"channel" => "ticker", "data" => [head | _]} ->
        sell_price = head["ask"]
        buy_price = head["bid"]
        trading_pair = head["symbol"]
        Phoenix.PubSub.broadcast(KrakenPrices.PubSub, "prices", {:price_update, %{trading_pair => %{"buy_price" => buy_price, "sell_price" => sell_price}}})

        {:ok, state}
      _ ->
        {:ok, state}
    end

    {:ok, state}
  end

  @impl true
  def handle_info({:subscribe, pair_batch}, state) do
    payload =
      Jason.encode!(%{
        method: "subscribe",
        params: %{
          channel: "ticker",
          symbol: pair_batch
        }
      })

    {:reply, {:text, payload}, state}
  end
end
