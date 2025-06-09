defmodule KrakenPrices.Services.GetTradingPairsService do
  @moduledoc """
    Fetches the list of available trading pairs from Kraken's REST API
  """

  def get_trading_pairs do
    try do
      HTTPoison.get!("https://api.kraken.com/0/public/AssetPairs").body
      |> Jason.decode!()
      |> Map.get("result")
      |> Map.values()
      |> Enum.map(fn x -> x["wsname"] end)
      |> Enum.filter(fn p -> p != nil && to_string(p) |> String.trim() != "" end)
    rescue
      e -> IO.puts("ERROR: " <> e.message)
      []
    end
  end
end
