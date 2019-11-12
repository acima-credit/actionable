# frozen_string_literal: true

module Actionable
  class Steps
    class Action < Base
      def initialize(klass, options = {})
        super klass.action_name, options
        @klass = klass
      end

      def run(instance)
        return [:skip, nil] if skip?(instance)

        result   = run_action instance
        fixtures = select_fixtures result.fixtures
        instance.update_fixtures fixtures
        return [:success, result] if result.success?

        instance.fail result.code, result.message, result.errors
        [:fail, result]
      end

      private

      def run_action(instance)
        params = @options[:params].map { |x| instance.fixtures[x] }
        @klass.run(*params)
      end

      def select_fixtures(fixtures)
        return fixtures unless @options[:fixtures].present?

        selected = @options[:fixtures].map(&:to_s)
        fixtures.select { |k, _| selected.include? k.to_s }
      end
    end
  end
end
