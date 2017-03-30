require 'set'

module Actionable
  class Action

    class << self

      def actions
        @actions ||= Set.new
      end

      def action(name)
        actions.add name.to_sym
      end

      alias :step :action

      def set_model(name)
        @model_name = name.to_sym
      end

      def model
        @model_name.present? ? @model_name.to_s.camelize.constantize : nil
      end

      def run(*args, &blk)
        instance = new *args
        run_with_transaction(instance, &blk) || run_without_transaction(instance, &blk)
        instance.result
      end

      alias_method :call, :run

      private

      def run_with_transaction(instance, &blk)
        return false if model.nil?

        model.transaction { run_without_transaction instance, &blk }
      end

      def run_without_transaction(instance, &blk)
        raise 'No actions have been defined' unless actions.present?

        run_through_actions instance
        finalize_if_necessary instance
        yield_on_success instance, &blk
      end

      def run_through_actions(instance)
        actions.each do |action|
          break if instance.finished?
          instance.send action
        end
      end

      def finalize_if_necessary(instance)
        unless instance.finished?
          instance.send(:succeed, 'Completed successfully.')
        end
      end

      def yield_on_success(instance)
        return unless block_given? && instance.result.success?

        yield instance.result
      end

    end

    attr_reader :result

    def initialize
      @result = nil
    end

    def succeed(message = nil, code = :success, errors: {})
      @result = ::Actionable::Success.new code: code, message: message, errors: errors, fixtures: fixtures
      false
    end

    def fail(code, message = nil, errors = {})
      @result = ::Actionable::Failure.new code: code, message: message, errors: errors, fixtures: fixtures
      false
    end

    def finished?
      @result.present?
    end

    def run
      raise 'You should define your own run method!'
    end

    private

    def fixtures
      instance_values.select { |k, _| k != 'result' }.with_indifferent_access
    end

  end
end
