require 'bundler/setup'
require 'actionable'
require 'support/string'
require 'support/database'
require 'actionable/rspec/matchers'
require 'actionable/proxy_validator'
require 'support/actionable'

ENV['ACTIONABLE_BACKTRACE_QTY']   ||= '3'
ENV['ACTIONABLE_SHORT_BACKTRACE'] ||= 'true'

require 'rspec/core/formatters/base_text_formatter'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.add_formatter :json, 'spec/results/examples.json'
  config.add_formatter :documentation, 'spec/results/examples.txt'
  config.add_formatter :html, 'spec/results/examples.html'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
