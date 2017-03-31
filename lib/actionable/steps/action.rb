module Actionable
  class Steps
    class Action < Base

      def initialize(klass, options = {})
        super klass.action_name, options
        @klass = klass
      end

      def run(instance)
        result = run_action instance
        instance.set_fixtures result.fixtures
        return if result.success?

        instance.fail result.code, result.message, result.errors
      end

      private

      def run_action(instance)
        params = @options[:params].map { |x| instance.fixtures[x] }
        @klass.run *params
      end

    end
  end
end
