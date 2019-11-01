# frozen_string_literal: true

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

      def to_s
        format '#<%s name=%s, options=%s>', self.class.name, name.inspect, options.inspect
      end

      alias inspect to_s

      # redefine equality using #eql? and #hash to get valid uniqueness checks
      def eql?(other)
        self.class == other.class && name == other.name
      end

      alias == eql?
      alias equal? eql?

      def hash
        [self.class.name, name].hash
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
