ExUnit.start()
Application.ensure_all_started(:bypass)
Mox.defmock(KrakenPrices.MockWebSocketClient, for: KrakenPrices.Services.WebSocketClient)
Application.put_env(:kraken_prices, :websocket_client, KrakenPrices.MockWebSocketClient)
