defmodule KrakenPrices.Services.GetTradingPairsService do
  @moduledoc """
    Fetches the list of available trading pairs from Kraken's REST API
  """

  def get_trading_pairs(url \\ "https://api.kraken.com/0/public/AssetPairs") do
    try do
      HTTPoison.get!(url).body
      |> Jason.decode!()
      |> Map.get("result")
      |> Map.values()
      |> Enum.map(fn x -> x["wsname"] end)
      |> Enum.filter(fn p -> p != nil && to_string(p) |> String.trim() != "" end)
    rescue
      e -> IO.puts("ERROR: " <> Exception.message(e))
      []
    end
  end
end
