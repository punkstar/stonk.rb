# frozen_string_literal: true

require "test_helper"

module Stonk
  class StockTest < Minitest::Test
    def test_stock_price
      assert_equal(100, Stonk::Stock.new("AAPL", 100).price)
    end

    def test_stock_symbol
      assert_equal("AAPL", Stonk::Stock.new("AAPL", 100).symbol)
    end
  end
end
