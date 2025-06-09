defmodule KrakenPricesWeb.PricesLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(KrakenPrices.PubSub, "prices")

    {:ok, assign(socket, :prices, %{})}
  end

  def handle_info({:price_update, data}, socket) do
    updated_prices = Map.merge(socket.assigns.prices, data)

    {:noreply, assign(socket, prices: updated_prices)}
  end

  def render(assigns) do
    ~H"""
    <h1>Kraken Prices</h1>
    <ul>
      <%= for {pair, %{"buy_price" => buy, "sell_price" => sell}} <- @prices do %>
        <li><%= pair %>: Buy: <%= buy %> / Sell: <%= sell %></li>
      <% end %>
    </ul>
    """
  end
end
