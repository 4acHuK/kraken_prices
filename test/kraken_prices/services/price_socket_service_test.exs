defmodule KrakenPrices.Services.PriceSocketServiceTest do
  use ExUnit.Case, async: false

  alias KrakenPrices.Services.PriceSocketService

  setup do
    {:ok, pid} = start_supervised({PriceSocketService, []})
    %{pid: pid}
  end

  test "handle_info sends ticker subscription payload", %{pid: pid} do
    batch = ["BTC/USD", "ETH/USD"]

    send(pid, {:subscribe, batch})

    state = nil
    payload =
      Jason.encode!(%{
        method: "subscribe",
        params: %{
          channel: "ticker",
          symbol: batch
        }
      })

    assert PriceSocketService.handle_info({:subscribe, batch}, state) ==
             {:reply, {:text, payload}, state}
  end

  test "handle_frame decodes ticker message and broadcasts it", %{pid: _pid} do
    state = nil

    message =
      Jason.encode!(%{
        "channel" => "ticker",
        "data" => [
          %{
            "ask" => "123.45",
            "bid" => "122.95",
            "symbol" => "BTC/USD"
          }
        ]
      })

    Phoenix.PubSub.subscribe(KrakenPrices.PubSub, "prices")

    {:ok, _new_state} = PriceSocketService.handle_frame({:text, message}, state)

    assert_receive {:price_update,
      %{"BTC/USD" => %{"buy_price" => "122.95", "sell_price" => "123.45"}}}
  end

  test "handle_frame ignores unknown message format" do
    state = nil

    unknown_msg = Jason.encode!(%{"event" => "heartbeat"})

    assert PriceSocketService.handle_frame({:text, unknown_msg}, state) == {:ok, state}
  end
end
