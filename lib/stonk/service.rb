# frozen_string_literal: true

module Stonk
  class Service
    def initialize(lookup_adapters: [], cache_adapter: nil)
      @lookup_adapters = lookup_adapters
      @cache_adapter = cache_adapter
    end

    def get_stock_price(stock_symbol)
      get_stock_price_from_adapters(stock_symbol).tap do |price|
        @cache_adapter.set_stock_price(stock_symbol, price) if has_cache_adapter?
      end
    end

    private

    def get_stock_price_from_adapters(stock_symbol)
      @lookup_adapters.each do |adapter|
        Stonk.logger.debug("Looking up #{stock_symbol} from #{adapter.class.name}")
        return adapter.get_stock_price(stock_symbol)
      rescue Stonk::Adapter::AdapterError => e
        Stonk.logger.warn("Error looking up #{stock_symbol} from #{adapter.class.name}: #{e.message}")
        next
      end

      nil
    end

    def has_cache_adapter?
      !@cache_adapter.nil?
    end
  end
end
