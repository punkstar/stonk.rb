# frozen_string_literal: true

require_relative "stonk/version"
require "logger"
module Stonk
  class Error < StandardError; end

  autoload :Adapter, "stonk/adapter"
  autoload :Service, "stonk/service"
  autoload :Stock, "stonk/stock"
  autoload :Money, "stonk/money"

  class << self
    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.level = ENV["STONK_LOG_LEVEL"] || Logger::ERROR
      end
    end
  end
end
