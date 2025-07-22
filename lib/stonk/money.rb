# frozen_string_literal: true

require "bigdecimal"
require "delegate"

module Stonk
  class Money < SimpleDelegator
    def initialize(amount)
      super(BigDecimal(amount))
    end
  end
end
