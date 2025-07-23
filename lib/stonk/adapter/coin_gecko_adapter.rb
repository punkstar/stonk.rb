# frozen_string_literal: true

module Stonk
  module Adapter
    class CoinGeckoAdapter
      def initialize(api_key)
        @api_key = api_key
      end

      def get_stock_price(stock_symbol)
        raise Stonk::Adapter::StockNotFound unless stock_symbol.end_with?(".CRYPTO")

        coin = stock_symbol.gsub(".CRYPTO", "")

        make_request(coin).then do |response|
          raise Stonk::Adapter::StockNotFound if response.empty?

          Stonk::Money.new(response.first.dig("current_price"))
        end
      end

      private

      def make_request(coin)
        url = URI("https://api.coingecko.com/api/v3/coins/markets?vs_currency=USD&symbols=" + coin)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["accept"] = "application/json"
        request["x-cg-demo-api-key"] = @api_key

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        elsif response.is_a?(Net::HTTPTooManyRequests)
          raise Stonk::Adapter::RateLimitExceeded, "Too many requests"
        else
          raise Stonk::Adapter::ServerError, "Failed to fetch price for #{coin}: #{response.body}"
        end
      end
    end
  end
end
