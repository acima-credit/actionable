module Actionable
  class ActionRunner
    def initialize(klass)
      @klass = klass
    end

    def run(*args, &blk)
      @instance = @klass.new(*args)

      if @klass.model
        run_with_transaction(&blk)
      else
        run_without_transaction(&blk)
      end

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

      yield_on_success(&blk)
    end

    def run_through_main_steps
      @klass.steps.each do |step|
        break if @instance.finished?

        step.run @instance
      end
    end

    def finalize_if_necessary
      return if @instance.finished?

      @instance.send(:succeed)
    end

    def run_through_success_steps
      return unless @instance.result.success?

      @klass.success_steps.each do |step|
        step.run @instance
        @instance.result.fixtures = @instance.fixtures
      end
    end

    def yield_on_success
      return unless block_given? && @instance.result.success?

      yield @instance.result
    end

    def run_through_failure_steps
      return unless @instance.result.failure?

      @klass.failure_steps.each do |step|
        step.run @instance
        @instance.result.fixtures = @instance.fixtures
      end
    end
  end
end
