# frozen_string_literal: true

require "test_helper"

module Stonk
  module Adapter
    class AlphaVantageAdapterTest < Minitest::Test
      def setup
        @adapter = Stonk::Adapter::AlphaVantageAdapter.new(ENV["ALPHA_VANTAGE_TEST_API_KEY"] || "bogus")
      end

      def test_get_stock_price
        VCR.use_cassette("alpha_vantage/stock_aapl", tag: :alpha_vantage) do
          response = @adapter.get_stock_price("AAPL")

          assert_kind_of(Stonk::Money, response)
          assert_predicate(response, :positive?)
          assert_equal(214.4, response.to_f)
        end
      end

      def test_raises_when_stock_not_found
        VCR.use_cassette("alpha_vantage/stock_blahblah", tag: :alpha_vantage) do
          assert_raises(Stonk::Adapter::StockNotFound) do
            @adapter.get_stock_price("BLAHBLAH")
          end
        end
      end

      def test_raises_when_server_error
        stub_request(:get, url_for("AAPL"))
          .to_return(status: 500, body: "Internal Server Error")

        assert_raises(Stonk::Adapter::ServerError) do
          VCR.turned_off do
            @adapter.get_stock_price("AAPL")
          end
        end
      end

      def test_raises_when_rate_limit_exceeded
        stub_request(:get, url_for("AAPL"))
          .to_return(status: 429, body: "Rate Limit Exceeded").then
          .to_return(status: 200, body: successful_response_body)

        assert_raises(Stonk::Adapter::RateLimitExceeded) do
          VCR.turned_off do
            @adapter.get_stock_price("AAPL")
          end
        end
      end

      def test_retries_when_rate_limit_exceeded
        stub_request(:get, url_for("AAPL"))
          .to_return(status: 429, body: "Rate Limit Exceeded").then
          .to_return(status: 429, body: "Rate Limit Exceeded").then
          .to_return(status: 429, body: "Rate Limit Exceeded")

        retryable_adapter = Stonk::Adapter::AlphaVantageAdapter.new(
          "apikey",
          retry_on_rate_limit: true,
          rate_limit_sleep_seconds: 0,
          rate_limit_retry_count: 3,
        )

        assert_raises(Stonk::Adapter::RateLimitRetryExceeded) do
          VCR.turned_off do
            retryable_adapter.get_stock_price("AAPL")
          end
        end
      end

      private

      def url_for(stock_symbol)
        "https://alpha-vantage.p.rapidapi.com/query?datatype=json&function=GLOBAL_QUOTE&symbol=#{stock_symbol}"
      end

      def successful_response_body
        {
          "Global Quote": {
            "01. symbol": "AAPL",
            "02. open": "212.1450",
            "03. high": "214.6500",
            "04. low": "211.8101",
            "05. price": "213.5500",
            "06. volume": "34955836",
            "07. latest trading day": "2025-07-03",
            "08. previous close": "212.4400",
            "09. change": "1.1100",
            "10. change percent": "0.5225%",
          },
        }.to_json
      end
    end
  end
end
