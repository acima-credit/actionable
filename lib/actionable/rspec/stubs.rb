require 'actionable/rspec/matchers'

module Actionable
  class Action
    def self.mock_success(fixtures = {})
      message = fixtures.delete(:message) || DEFAULT_SUCCESS_MESSAGE
      Success.new code: :success, message: message, errors: {}, fixtures: fixtures
    end

    def self.mock_failure(code, message = '', fixtures = {})
      errors = fixtures.delete(:errors) || {}
      Failure.new code: code, message: message, errors: errors, fixtures: fixtures
    end
  end
end

module Actionable
  module RspecStubs
    def stub_actionable_success(klass, fixtures = {})
      result = klass.mock_success fixtures
      expect(klass).to receive(:run).and_return result
    end

    def stub_actionable_failure(klass, code, message = '', fixtures = {})
      result = klass.mock_failure code, message, fixtures
      expect(klass).to receive(:run).and_return result
    end
  end
end

RSpec.configure do |config|
  config.include Actionable::RspecStubs
end
