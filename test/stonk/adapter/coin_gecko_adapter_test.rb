# frozen_string_literal: true

module Stonk
  module Adapter
    class CoinGeckoAdapterTest < Minitest::Test
      def setup
        @adapter = Stonk::Adapter::CoinGeckoAdapter.new(ENV["COIN_GECKO_TEST_API_KEY"] || "bogus")
      end

      def test_raises_when_stock_symbol_does_not_end_with_dot_crypto
        assert_raises(Stonk::Adapter::StockNotFound) do
          @adapter.get_stock_price("AAPL")
        end
      end

      def test_raises_when_stock_not_found
        VCR.use_cassette("coin_gecko/stock_blahblah", tag: :coin_gecko) do
          assert_raises(Stonk::Adapter::StockNotFound) do
            @adapter.get_stock_price("BLAHBLAH.CRYPTO")
          end
        end
      end

      def test_get_stock_price
        VCR.use_cassette("coin_gecko/stock_btc", tag: :coin_gecko) do
          response = @adapter.get_stock_price("BTC.CRYPTO")

          assert_equal(118395.0, response.to_f)
        end
      end

      def test_with_eth
        VCR.use_cassette("coin_gecko/stock_eth", tag: :coin_gecko) do
          response = @adapter.get_stock_price("ETH.CRYPTO")

          assert_equal(3588.52, response.to_f)
        end
      end
    end
  end
end
