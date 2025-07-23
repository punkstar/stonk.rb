# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
require "minitest/test_task"

RuboCop::RakeTask.new

Minitest::TestTask.create do |t|
  t.warning = false
  t.test_prelude = <<~RUBY if ENV["COVERAGE"]
    require "simplecov"
    SimpleCov.start do
      add_filter %r{^/test/}
    end
  RUBY
end

task default: :test
