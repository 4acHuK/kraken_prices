defmodule KrakenPrices.Services.WebSocketClient do
  @callback start_link(url :: String.t(), module :: module(), state :: any()) ::
              {:ok, pid()} | {:error, any()}

  @callback send_frame(pid(), frame :: any()) :: :ok | {:error, any()}
end
