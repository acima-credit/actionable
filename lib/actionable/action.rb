module Actionable
  class Action
    class << self
      def steps
        @steps ||= Set.new
      end

      alias actions steps

      def step(name, options = {})
        steps.add Steps.build(name, options)
      end

      alias action step

      def set_model(name = :nothing)
        @model_name = name.to_sym
      end

      alias set_transactional_model set_model

      def model
        @model_name ? @model_name.to_s.camelize.constantize : nil
      end

      alias transactional_model model

      def inherited(subclass)
        subclass.set_model @model_name if @model_name
      end

      def run(*args, &blk)
        instance = new(*args)
        run_with_transaction(instance, &blk) || run_without_transaction(instance, &blk)
        instance.result
      end

      alias call run

      def action_name
        name.underscore
      end

      private

      def run_with_transaction(instance, &blk)
        return false if model.nil?

        model.transaction { run_without_transaction instance, &blk }
      end

      def run_without_transaction(instance, &blk)
        raise 'No steps have been defined' unless steps.present?

        run_through_actions instance
        finalize_if_necessary instance
        yield_on_success instance, &blk
      end

      def run_through_actions(instance)
        steps.each do |step|
          break if instance.finished?
          step.run instance
        end
      end

      def finalize_if_necessary(instance)
        return if instance.finished?

        instance.send(:succeed, 'Completed successfully.')
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
      @result = Success.new code: code, message: message, errors: errors, fixtures: fixtures
      false
    end

    def fail(code, message = nil, errors = {})
      @result = Failure.new code: code, message: message, errors: errors, fixtures: fixtures
      false
    end

    def finished?
      @result.present?
    end

    def run
      raise 'You should define your own run method!'
    end

    def fixtures
      instance_values.
        select { |k, _| k != 'result' || k.start_with?('_') }.
        with_indifferent_access
    end

    def update_fixtures(fields = {})
      fields.each { |k, v| instance_variable_set "@#{k}", v }
    end
  end
end
