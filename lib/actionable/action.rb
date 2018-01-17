module Actionable
  class Action
    class << self
      def steps
        @steps ||= Set.new
      end

      alias actions steps

      def success_steps
        @success_steps ||= Set.new
      end

      def failure_steps
        @failure_steps ||= Set.new
      end

      def always_steps
        @always_steps ||= Set.new
      end

      def add_step(type, step)
        added = send(type).add? step
        return unless added

        log_action '%s : added : %s', type, added.to_s
      end

      def step(name, options = {})
        add_step :steps, Steps.build(name, options)
      end

      alias action step

      def case_step(name, options = {}, &blk)
        add_step :steps, Steps::Case.new(name, options, &blk)
      end

      alias case_action case_step

      def on_success(name, options = {})
        add_step :success_steps, Steps.build(name, options)
      end

      def on_failure(name, options = {})
        add_step :failure_steps, Steps.build(name, options)
      end

      def always(name, options = {})
        add_step :always_steps, Steps.build(name, options)
      end

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
        subclass.action_logger @action_logger if @action_logger
        subclass.action_logger_severity @action_logger_severity if @action_logger_severity
      end

      def run(*args, &blk)
        ActionRunner.new(self).run(*args, &blk)
      end

      alias call run

      def action_name
        name.underscore
      end

      def action_logger(value = :not_set)
        @action_logger = value unless value == :not_set
        @action_logger
      end

      def action_logger_severity(value = :not_set)
        @action_logger_severity = value unless value == :not_set
        @action_logger_severity || :debug
      end

      def log_action(str, *args)
        return unless action_logger

        msg = format str, *args
        msg = format '%s : %s | %s', self.class.name, caller(1).first[/`.*'/][1..-2], msg
        action_logger.send action_logger_severity, msg
      end
    end

    attr_reader :result

    def initialize
      @result = nil
    end

    DEFAULT_SUCCESS_MESSAGE = 'Completed successfully.'.freeze

    def succeed(message = DEFAULT_SUCCESS_MESSAGE, code = :success, errors: {})
      @result = Success.new code: code, message: message, errors: errors, fixtures: fixtures
      log_action 'message : %s', message
      false
    end

    def succeed!(*args)
      succeed(*args)
      raise SuccessError, @result.message
    end

    def fail(code, message = nil, errors = {})
      @result = Failure.new code: code, message: message, errors: errors, fixtures: fixtures
      log_action 'code : %s | message : %s | errors : %s', code, message, errors.inspect
      false
    end

    # rubocop:disable UnreachableCode
    def fail!(*args)
      fail(*args)
      raise FailureError, @result.message
    end

    # rubocop:enable UnreachableCode

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

    def log_action(str, *args)
      return unless action_logger

      msg = format str, *args
      msg = format '%s : %s | %s', self.class.name, caller(1).first[/`.*'/][1..-2], msg
      action_logger.send action_logger_severity, msg
    end

    private

    def action_logger
      self.class.action_logger
    end

    def action_logger_severity
      self.class.action_logger_severity
    end
  end
end
