defmodule KrakenPrices.Services.WebSocketClientImpl do
  @behaviour KrakenPrices.Services.WebSocketClient

  defdelegate start_link(url, module, state), to: WebSockex
  defdelegate send_frame(pid, frame), to: WebSockex
end
