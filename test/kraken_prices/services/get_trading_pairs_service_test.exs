defmodule KrakenPrices.Services.GetTradingPairsServiceTest do
  use ExUnit.Case, async: true
  alias KrakenPrices.Services.GetTradingPairsService
  import ExUnit.CaptureIO

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "get_trading_pairs returns a list of wsname pairs", %{bypass: bypass} do
    response = %{
      "result" => %{
        "XBTUSD" => %{"wsname" => "XBT/USD"},
        "ETHUSD" => %{"wsname" => "ETH/USD"},
        "BAD" => %{"wsname" => nil}
      }
    }

    Bypass.expect(bypass, fn conn ->
      assert conn.request_path == "/0/public/AssetPairs"
      assert conn.method == "GET"

      Plug.Conn.resp(conn, 200, Jason.encode!(response))
    end)

    url = "http://localhost:#{bypass.port}/0/public/AssetPairs"
    pairs = GetTradingPairsService.get_trading_pairs(url)

    assert pairs == ["ETH/USD", "XBT/USD"]
  end

  test "get_trading_pairs handles API errors", %{bypass: bypass} do
    Bypass.down(bypass)

    url = "http://localhost:#{bypass.port}/0/public/AssetPairs"

    output = capture_io(fn ->
      result = GetTradingPairsService.get_trading_pairs(url)
      assert result == []
    end)

    assert output =~ "ERROR:"
  end
end
