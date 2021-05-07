# frozen_string_literal: true

module Actionable
  class History
    class Step
      attr_reader :section, :name, :start_time, :took, :code, :history

      def initialize(section, name)
        @section = section
        @name = name
        @start_time = current_time
        @end_time = nil
        @took = nil
        @code = nil
        @history = nil
      end

      def stop(code, history = nil)
        @code = code
        @end_time = current_time
        @took = @end_time - @start_time
        @history = history
      end

      def to_ary
        [
          @section,
          @name,
          @start_time,
          format('%.6f', @took),
          @code,
          @history
        ]
      end

      def as_json
        to_ary.map { |x| x.respond_to?(:as_json) ? x.as_json : x }
      end

      private

      def current_time
        diff = nano_time(:real) - nano_time(:mono)
        nsec = nano_time(:mono) + diff
        Time.at nsec / 1_000_000_000, nsec % 1_000_000_000 / 1_000.0
      end

      def nano_time(type)
        Process.clock_gettime type == :real ? Process::CLOCK_REALTIME : Process::CLOCK_MONOTONIC, :nanosecond
      end
    end

    def initialize
      @steps = HashWithIndifferentAccess.new
    end

    def measure(section, step, event, code = nil, history = nil)
      case event
      when :start
        start section, step
      when :stop
        stop section, step, code, history
      end
    end

    delegate :keys, :values, :size, :[], to: :@steps
    delegate :map, :select, :find, to: :values

    def step_names
      map(&:name)
    end

    def took
      map(&:took).compact.sum
    end

    def as_json
      map(&:as_json)
    end

    def to_json(options = {})
      JSON.generate as_json, options
    end

    private

    def start(section, step)
      @steps[step.name] = Step.new(section, step.name)
    end

    def stop(section, step, code, nested_history)
      @steps[step.name] ||= Step.new(section, step.name)
      @steps[step.name].stop code, nested_history
    end
  end
end
