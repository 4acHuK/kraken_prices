defmodule KrakenPrices.Services.WebsocketClientTest do
  use ExUnit.Case, async: false
  import Mox

  alias KrakenPrices.Services.PriceSocketService

  setup :verify_on_exit!

  test "starts the socket with the mocked client" do
    KrakenPrices.MockWebSocketClient
    |> expect(:start_link, fn "wss://ws.kraken.com/v2", _mod, _state -> {:ok, self()} end)

    assert {:ok, _pid} =
             PriceSocketService.start_link(
               websocket_client: KrakenPrices.MockWebSocketClient
             )
  end
end
