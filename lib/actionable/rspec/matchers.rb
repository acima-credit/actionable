require 'actionable'

module Actionable
  module RspecMatchers
    def perform_actionable(*args)
      PerformActionableMatcher.new(*args)
    end

    class PerformActionableMatcher
      attr_reader :type, :matched

      def initialize(*args)
        @args = args
      end

      def and_succeed(message = Action::DEFAULT_SUCCESS_MESSAGE)
        @type      = :success
        @s_message = message
        self
      end

      def and_fail(code, message = nil)
        @type      = :failure
        @f_code    = code
        @f_message = message
        self
      end

      def and_raise(klass, message = nil)
        @type      = :exception
        @e_klass   = klass
        @e_message = message
        self
      end

      def matches?(klass)
        return @matched unless @matched.nil?

        @klass = klass
        get_result_or_exception

        case @type
        when :success
          @matched = passes_success
        when :failure
          @matched = passes_failure
        when :exception
          @matched = passes_exception
        else
          raise "Unknown test type [#{@type}]"
        end

        yield result, exception if @matched && block_given?

        @matched
      end

      def failure_message
        matched ? '' : failure_messages.join("\n  ")
      end

      private

      attr_reader :klass, :args, :exception, :result

      # rubocop:disable Lint/RescueException
      def get_result_or_exception
        @exception = nil
        @result    = klass.run(*args)
      rescue Exception => e
        @result    = nil
        @exception = e
      end

      # rubocop:enable Lint/RescueException

      def passes_success
        @result.present? && @result.success? && pass_success_message
      end

      def pass_success_message
        @result.message.to_s == @s_message.to_s
      end

      def passes_failure
        @result.present? && @result.failure? && @result.code == @f_code && pass_failure_message
      end

      def pass_failure_message
        (@f_message.present? ? (@result.message.to_s == @f_message.to_s) : true)
      end

      def passes_exception
        @exception.present? && @exception.class == @e_klass && pass_exception_message
      end

      def pass_exception_message
        (@e_message.present? ? (@exception.message == @e_message) : true)
      end

      def failure_messages
        messages = ["expected #{klass.name} to run with #{args.inspect}"]
        case type
        when :success
          messages << failure_messages_for_success
        when :failure
          messages << failure_messages_for_failure
        when :exception
          messages << failure_messages_for_exception
        end
        messages
      end

      def failure_messages_for_success
        messages = []
        if @exception.present?
          messages << "and succeed with message #{@s_message.inspect}"
          messages << "but a #{@exception.class.name} exception was raised"
          messages << "  with message #{@exception.message.inspect}"
          add_backtrace_lines messages
        else
          failure_messages_for_success_no_exception(messages)
        end
        messages
      end

      def failure_messages_for_success_no_exception(messages)
        if @result.success?
          messages << 'and although it succeeded'
          if @s_message.present? && @result.message.to_s != @s_message.to_s
            messages << "the message was #{@result.message.to_s.inspect} instead of #{@s_message.to_s.inspect}"
          end
        else
          messages << "and succeed with message #{@s_message.inspect}"
          messages << "but it failed with code :#{@result.code} and message #{@result.message.inspect}"
        end
      end

      def failure_messages_for_failure
        messages = []
        if @exception.present?
          messages << "and fail with code :#{@f_code} and message #{@f_message.inspect}"
          messages << "but a #{@exception.class.name} exception was raised"
          messages << "  with message #{@exception.message.inspect}"
          add_backtrace_lines messages
        else
          failure_messages_for_failure_no_exception(messages)
        end
        messages
      end

      def add_backtrace_lines(msgs)
        qty = ENV.fetch('ACTIONABLE_BACKTRACE_QTY', 5).to_i
        msgs << '  with backtrace:'
        @exception.backtrace[0, qty].each do |line|
          line = format_backtrace_line line
          msgs << line if line.present?
        end
      end

      def format_backtrace_line(line)
        line  = line.to_s.strip
        match = line.match(/(.*):(.*):in `(.*)'/i)
        return nil unless match.present?

        short = ENV.fetch('ACTIONABLE_SHORT_BACKTRACE', 'false') == 'true'
        path  = short ? match[1].split('/').last : match[1]
        format %[    %s:%i in `%s'], path, match[2], match[3]
      end

      def failure_messages_for_failure_no_exception(messages)
        if @result.success?
          messages << "and fail with code :#{@f_code} and message #{@f_message.inspect}"
          messages << "but it succeeded with #{@result.message.inspect}"
        else
          messages << 'and although it failed'
          messages << "the code was :#{@result.code} instead of :#{@f_code}" if @result.code != @f_code
          if @f_message.present? && @result.message.to_s != @f_message.to_s
            messages << "the message was #{@result.message.to_s.inspect} instead of #{@f_message.to_s.inspect}"
          end
        end
      end

      def failure_messages_for_exception
        msg      = "and throw a #{@e_klass} exception"
        msg      += " with message #{@e_message.inspect}" if @e_message.present?
        messages = [msg]

        if @exception.nil?
          messages << 'but no exception was raised'
        else
          messages << 'and although an exception was raised'
          messages << "  the class was #{@exception.class.name}" if @exception.class.name != @e_klass.name
          if @e_message.present? && @exception.message != @e_message
            messages << "  the message was #{@exception.message.inspect}"
          end
          add_backtrace_lines messages
        end
        messages
      end
    end
  end
end

RSpec.configure do |config|
  config.include Actionable::RspecMatchers
end
