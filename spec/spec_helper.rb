require 'bundler/setup'
require 'actionable'
require 'support/string'
require 'support/database'
require 'actionable/rspec/matchers'
require 'actionable/rspec/stubs'
require 'actionable/proxy_validator'
require 'support/actionable'

ENV['ACTIONABLE_BACKTRACE_QTY']   ||= '3'
ENV['ACTIONABLE_SHORT_BACKTRACE'] ||= 'true'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
