# frozen_string_literal: true

require "fileutils"
require "json"

module Stonk
  module Adapter
    class FileCacheAdapter
      def initialize(cache_file_path, default_ttl: 60 * 60)
        @cache_file_path = cache_file_path
        @default_ttl = default_ttl
        @data = nil
      end

      def get_stock_price(stock_symbol)
        load_data

        raise Stonk::Adapter::StockNotFound, "Stock not found: #{stock_symbol}" unless @data.key?(stock_symbol)

        entry = @data[stock_symbol]

        if Time.now.to_i >= entry["expires_at"]
          @data.delete(stock_symbol)
          save_data
          raise Stonk::Adapter::StockNotFound, "Stock not found: #{stock_symbol}"
        end

        entry["price"]
      end

      def set_stock_price(stock_symbol, price, ttl: nil)
        return if price.nil?

        load_data

        ttl_seconds = ttl || @default_ttl
        expires_at = Time.now.to_i + ttl_seconds

        @data[stock_symbol] = {
          "price" => price,
          "expires_at" => expires_at,
        }

        save_data
      end

      def clear_cache
        FileUtils.rm_f(cache_path)
      end

      def clear_expired_entries
        load_data
        original_size = @data.size

        @data.delete_if do |_symbol, entry|
          Time.now.to_i >= entry["expires_at"]
        end

        if @data.size < original_size
          save_data
          Stonk.logger.debug("[FileCacheAdapter] Cleared #{original_size - @data.size} expired entries")
        end
      end

      private

      def load_data
        @data = JSON.parse(File.read(cache_path))
      rescue JSON::ParserError
        @data = {}
      end

      def save_data
        Stonk.logger.debug("[FileCacheAdapter] Saving #{@data.to_json} to #{cache_path}")
        File.write(cache_path, @data.to_json)
      end

      def cache_path
        FileUtils.touch(@cache_file_path) unless File.exist?(@cache_file_path)

        @cache_file_path
      end
    end
  end
end
