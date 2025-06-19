defmodule KrakenPricesWeb.PricesLiveTest do
  use KrakenPricesWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "renders initial state", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Kraken Prices"
    assert html =~ "<ul>"
  end

  test "updates prices on :price_update message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    send(view.pid, {:price_update, %{"BTC/USD" => %{"buy_price" => "50000", "sell_price" => "50100"}}})

    assert render(view) =~ "BTC/USD: Buy: 50000 / Sell: 50100"
  end
end
