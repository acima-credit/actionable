# frozen_string_literal: true

module Actionable
  class Steps
    class Case < Base
      def initialize(name, options = {}, &blk)
        super
        build_cases blk
      end

      def on(value, name, options = {})
        @cases << [value, Steps.build(name, options)]
      end

      def default(name, options = {})
        @default_step = Steps.build(name, options)
      end

      def run(instance)
        @value = instance.fixtures[name] || instance.send(name)
        ran    = false

        @cases.each do |case_value, step|
          next unless value_cmp(@value, case_value)

          step.run instance
          ran = true
          break
        end

        @default_step.run instance if @default_step && !ran

        [instance.result&.code || :unknown, nil]
      end

      private

      def build_cases(blk)
        @cases   = []
        @default = nil
        instance_eval(&blk)
      end

      def value_cmp(value, case_value)
        case case_value
        when Regexp
          value.to_s.match case_value
        when Array
          case_value.any? { |x| value.to_s == x.to_s }
        else
          value.to_s == case_value.to_s
        end
      end
    end
  end
end
