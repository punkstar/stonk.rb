# frozen_string_literal: true

module Stonk
  module Adapter
    class AdapterError < Error; end

    class ConfigurationError < AdapterError; end
    class StockNotFound < AdapterError; end
    class RateLimitExceeded < AdapterError; end
    class RateLimitRetryExceeded < AdapterError; end
    class ServerError < AdapterError; end

    autoload :AlphaVantageAdapter, "stonk/adapter/alpha_vantage_adapter"
    autoload :CoinGeckoAdapter, "stonk/adapter/coin_gecko_adapter"
    autoload :FileCacheAdapter, "stonk/adapter/file_cache_adapter"
  end
end
