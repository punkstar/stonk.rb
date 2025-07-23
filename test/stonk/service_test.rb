# frozen_string_literal: true

require "test_helper"

module Stonk
  class ServiceTest < Minitest::Test
    def setup
      @cache_ttl = 60
      @cache_file_path = File.join(Dir.tmpdir, "stonk_cache_#{SecureRandom.hex(8)}.json")
      @cache_adapter = Stonk::Adapter::FileCacheAdapter.new(@cache_file_path, default_ttl: @cache_ttl)
      @service = Stonk::Service.new(
        lookup_adapters: [
          @cache_adapter,
          Stonk::Adapter::AlphaVantageAdapter.new(ENV["ALPHA_VANTAGE_TEST_API_KEY"] || "bogus"),
        ],
        cache_adapter: @cache_adapter,
      )
    end

    def teardown
      FileUtils.rm_f(@cache_file_path) if File.exist?(@cache_file_path)
      Timecop.return
    end

    def test_get_stock_price
      VCR.use_cassette("alpha_vantage/stock_aapl", tag: :alpha_vantage) do
        assert_in_delta(213.55, @service.get_stock_price("AAPL").to_f, 0.004)
      end
    end

    def test_reads_from_first_adapter_that_returns_a_price
      @cache_adapter.set_stock_price("AAPL", 100)

      VCR.use_cassette("alpha_vantage/stock_aapl", tag: :alpha_vantage) do
        assert_equal(100, @service.get_stock_price("AAPL"))
      end
    end

    def test_returns_nil_if_no_adapter_returns_a_price
      VCR.use_cassette("alpha_vantage/stock_blahblah", tag: :alpha_vantage) do
        assert_nil(@service.get_stock_price("BLAHBLAH"))
      end
    end

    def test_returning_stock_from_cache_does_not_increase_expiry_time
      Stonk::Adapter::AlphaVantageAdapter.any_instance.stubs(:get_stock_price)
        .raises(Stonk::Adapter::StockNotFound)

      Timecop.freeze(Time.now) do
        @cache_adapter.set_stock_price("AAPL", 100)
        @service.get_stock_price("AAPL")

        assert_equal(100, @cache_adapter.get_stock_price("AAPL"))

        Timecop.travel(Time.now + @cache_ttl + 10)

        assert_raises(Stonk::Adapter::StockNotFound) do
          @cache_adapter.get_stock_price("AAPL")
        end
      end
    end
  end
end
