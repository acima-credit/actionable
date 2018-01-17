module Actionable
  class Steps
    class Base
      attr_reader :name, :options

      def initialize(name, options = {})
        @name    = name.to_s
        @options = options
      end

      def run(_)
        return if skip?(instance)
      end

      private

      def skip?(instance)
        if @options.key?(:if)
          !run_condition(instance, @options[:if])
        elsif @options.key?(:unless)
          !!run_condition(instance, @options[:unless])
        else
          false
        end
      end

      def run_condition(instance, condition)
        if condition.is_a? Symbol
          instance.send condition
        else
          condition.call instance
        end
      end
    end
  end
end
