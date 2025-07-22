# frozen_string_literal: true

require "test_helper"

module Stonk
  class MoneyTest < Minitest::Test
    def test_money
      assert_equal(100, Stonk::Money.new(100))
    end

    def test_money_can_be_added
      assert_equal(200, Stonk::Money.new(100) + Stonk::Money.new(100))
    end

    def test_money_can_be_subtracted
      assert_equal(0, Stonk::Money.new(100) - Stonk::Money.new(100))
    end

    def test_money_can_be_multiplied
      assert_equal(100, Stonk::Money.new(100) * 1)
    end

    def test_money_can_be_divided
      assert_equal(100, Stonk::Money.new(100) / 1)
    end
  end
end
