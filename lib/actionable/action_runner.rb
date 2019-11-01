# frozen_string_literal: true

module Actionable
  class ActionRunner
    def initialize(klass)
      @klass = klass
    end

    def run(*args, &blk)
      @instance = @klass.new(*args)

      if @klass.model
        @instance.log_action 'running with a transaction from %s', @klass.model
        run_with_transaction(&blk)
      else
        @instance.log_action 'running without a transaction'
        run_without_transaction(&blk)
      end

      @instance.log_action 'result : %s : %s', @instance.result.code, @instance.result.message
      @instance.result
    end

    private

    def run_with_transaction(&blk)
      @klass.model.transaction { run_without_transaction(&blk) }
    end

    def run_without_transaction(&blk)
      raise 'No steps have been defined' unless @klass.steps.present?

      run_through_main_steps
      finalize_if_necessary

      run_through_success_steps
      run_through_failure_steps
      run_through_always_steps

      yield_on_success(&blk)
    end

    def run_step(section, step)
      measure section, step, :start
      exc = nil
      res = step.run @instance
    rescue SkippableError
      res = :skippable_error
    rescue StandardError => e
      exc = e
      res = :exception
    ensure
      measure section, step, :stop, res
      raise exc if exc

      return res
    end

    def measure(section, step, event, code = nil)
      return if @klass.measure == :none

      @instance.history.measure section, step, event, code, step.respond_to?(:history) ? step.history : nil
    end

    def run_through_main_steps
      @klass.steps.each do |step|
        if @instance.finished?
          @instance.log_action '%s : skipping since finished', step.name
          break
        end

        @instance.log_action '%s : start ...', step.name
        run_step :main, step
      end
    end

    def finalize_if_necessary
      return if @instance.finished?

      @instance.log_action 'step : finalizing ...'
      @instance.send(:succeed)
    end

    def run_through_success_steps
      return unless @instance.result.success?

      @klass.success_steps.each do |step|
        @instance.log_action '%s : start ...', step.name
        run_step :success, step
        @instance.result.fixtures = @instance.fixtures
      end
    end

    def yield_on_success
      return unless block_given? && @instance.result.success?

      @instance.log_action 'yielding on success ...'
      yield @instance.result
    end

    def run_through_failure_steps
      return unless @instance.result.failure?

      @klass.failure_steps.each do |step|
        @instance.log_action '%s : start ...', step.name
        run_step :failure, step
        @instance.result.fixtures = @instance.fixtures
      end
    end

    def run_through_always_steps
      @klass.always_steps.each do |step|
        @instance.log_action '%s : start ...', step.name
        run_step :always, step
        @instance.result.fixtures = @instance.fixtures
      end
    end
  end
end
