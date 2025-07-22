# frozen_string_literal: true

require "net/http"
require "json"

module Stonk
  module Adapter
    class AlphaVantageAdapter
      def initialize(api_key, retry_on_rate_limit: false, rate_limit_sleep_seconds: 3, rate_limit_retry_count: 10)
        @api_key = api_key
        @base_url = URI("https://alpha-vantage.p.rapidapi.com")
        @retry_on_rate_limit = retry_on_rate_limit
        @rate_limit_sleep_seconds = rate_limit_sleep_seconds
        @rate_limit_retry_count = rate_limit_retry_count
        @retry_attempts = 0

        raise ConfigurationError, "API key is required" if @api_key.nil?
        raise ConfigurationError, "Rate limit sleep seconds must be greater than 0" if @rate_limit_sleep_seconds < 0
      end

      def get_stock_price(stock_symbol)
        make_stock_price_request(stock_symbol).dig("Global Quote", "05. price").then do |price|
          raise Stonk::Adapter::StockNotFound, "Stock price not found for #{stock_symbol}" if price.nil?

          reset_retry_attempts
          Stonk::Money.new(price)
        end
      rescue Stonk::Adapter::RateLimitExceeded => e
        raise e unless @retry_on_rate_limit

        if @retry_attempts >= @rate_limit_retry_count
          raise Stonk::Adapter::RateLimitRetryExceeded, "Rate limit retry count exceeded"
        else
          Stonk.logger.warn("[AlphaVantage] Too many requests for #{stock_symbol}, sleeping for #{@rate_limit_sleep_seconds} seconds")
          sleep(@rate_limit_sleep_seconds) if @rate_limit_sleep_seconds > 0
          register_retry_attempt
          retry
        end
      rescue Net::HTTPError => e
        raise Stonk::Adapter::ServerError, "Failed to fetch stock price for #{stock_symbol}: #{e.message}"
      end

      private

      def make_stock_price_request(stock_symbol)
        params = {
          "function" => "GLOBAL_QUOTE",
          "symbol" => stock_symbol,
          "datatype" => "json",
        }

        make_request(params)
      end

      def make_request(params)
        uri = @base_url.dup
        uri.path = "/query"
        uri.query = URI.encode_www_form(params)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri)
        request["x-rapidapi-key"] = @api_key
        request["x-rapidapi-host"] = @base_url.host

        Stonk.logger.debug("[AlphaVantage] Making request to #{uri}")

        response = http.request(request)

        Stonk.logger.debug("[AlphaVantage] #{response.code}, #{response.body.gsub("\n", " ")}, #{response.to_hash}")

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        elsif response.is_a?(Net::HTTPTooManyRequests)
          raise Stonk::Adapter::RateLimitExceeded, "Too many requests"
        else
          raise Stonk::Adapter::ServerError, "Failed to fetch stock price for #{params}: #{response.body}"
        end
      end

      def register_retry_attempt
        @retry_attempts += 1
      end

      def reset_retry_attempts
        @retry_attempts = 0
      end
    end
  end
end
