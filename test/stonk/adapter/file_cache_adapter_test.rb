# frozen_string_literal: true

require "test_helper"

module Stonk
  module Adapter
    class FileCacheAdapterTest < Minitest::Test
      def setup
        @cache_file_path = File.join(Dir.tmpdir, "stonk_cache_#{SecureRandom.hex(8)}.json")
        @adapter = Stonk::Adapter::FileCacheAdapter.new(@cache_file_path)
        @adapter.set_stock_price("AAPL", 100)
      end

      def teardown
        FileUtils.rm_f(@cache_file_path)
        Timecop.return
      end

      def test_raises_when_stock_not_found
        assert_raises(Stonk::Adapter::StockNotFound) do
          @adapter.get_stock_price("NICK")
        end
      end

      def test_returns_stock_price
        assert_equal(100, @adapter.get_stock_price("AAPL"))
      end

      def test_sets_stock_price
        @adapter.set_stock_price("AAPL", 200)
        assert_equal(200, @adapter.get_stock_price("AAPL"))
      end

      def test_clears_cache
        @adapter.clear_cache
        assert_raises(Stonk::Adapter::StockNotFound) do
          @adapter.get_stock_price("AAPL")
        end
      end

      def test_ttl_expiration
        @adapter.set_stock_price("TSLA", 500, ttl: 1)
        assert_equal(500, @adapter.get_stock_price("TSLA"))

        Timecop.travel(Time.now + 2)

        assert_raises(Stonk::Adapter::StockNotFound) do
          @adapter.get_stock_price("TSLA")
        end
      end

      def test_custom_default_ttl
        custom_adapter = Stonk::Adapter::FileCacheAdapter.new(@cache_file_path, default_ttl: 2)
        custom_adapter.set_stock_price("GOOGL", 300)

        assert_equal(300, custom_adapter.get_stock_price("GOOGL"))

        Timecop.travel(Time.now + 3)

        assert_raises(Stonk::Adapter::StockNotFound) do
          custom_adapter.get_stock_price("GOOGL")
        end
      end

      def test_clear_expired_entries
        @adapter.set_stock_price("MSFT", 400, ttl: 1)
        @adapter.set_stock_price("AMZN", 600, ttl: 3)

        Timecop.travel(Time.now + 2)

        @adapter.clear_expired_entries

        assert_raises(Stonk::Adapter::StockNotFound) do
          @adapter.get_stock_price("MSFT")
        end

        assert_equal(600, @adapter.get_stock_price("AMZN"))
      end

      def test_ttl_metadata_structure
        @adapter.set_stock_price("NVDA", 800, ttl: 3600)

        raw_data = JSON.parse(File.read(@cache_file_path))
        entry = raw_data["NVDA"]

        assert(entry.is_a?(Hash))
        assert_equal(800, entry["price"])
        assert(entry.key?("expires_at"))
        assert(entry["expires_at"] > Time.now.to_i)
      end
    end
  end
end
