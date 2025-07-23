# frozen_string_literal: true

require "minitest/autorun"
require "mocha/minitest"
require "vcr"
require "webmock/minitest"
require "debug"
require "timecop"

require_relative "../lib/stonk"

Minitest::Test.make_my_diffs_pretty!

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into(:webmock)

  config.default_cassette_options = {
    re_record_interval: 60 * 60 * 24,
  }

  config.filter_sensitive_data("<ALPHA_VANTAGE_TEST_API_KEY>") { ENV["ALPHA_VANTAGE_TEST_API_KEY"] }
  config.filter_sensitive_data("<COIN_GECKO_TEST_API_KEY>") { ENV["COIN_GECKO_TEST_API_KEY"] }

  config.before_record(:alpha_vantage) do
    next unless ENV["ALPHA_VANTAGE_TEST_API_KEY"].nil?

    raise <<~ERROR
      Error ENV['ALPHA_VANTAGE_TEST_API_KEY'] is not configured.

      In order to record cassettes against the Alpha Vantage API, you need
      to set the ALPHA_VANTAGE_TEST_API_KEY environment variable.
    ERROR
  end

  config.before_record(:coin_gecko) do
    next unless ENV["COIN_GECKO_TEST_API_KEY"].nil?

    raise <<~ERROR
      Error ENV['COIN_GECKO_TEST_API_KEY'] is not configured.

      In order to record cassettes against the Coin Gecko API, you need
      to set the COIN_GECKO_TEST_API_KEY environment variable.
    ERROR
  end
end
