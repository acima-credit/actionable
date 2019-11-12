# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
SimpleCov.start

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
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  ROOT_PATH = Pathname.new File.expand_path(File.dirname(File.dirname(__FILE__)))

  Dir[ROOT_PATH.join('spec/support/*.rb')].each { |f| require f }
end
