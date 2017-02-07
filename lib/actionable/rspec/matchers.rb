require 'actionable'

module Actionable::RspecMatchers

  def perform_actionable(*args)
    PerformActionableMatcher.new *args
  end

  class PerformActionableMatcher

    attr_reader :matched, :failed_name

    def initialize(*args)
      @args = args
    end

    def and_succeed(message = nil)
      @s_message = message
      self
    end

    def and_fail(code, message = nil)
      @f_code    = code
      @f_message = message
      self
    end

    def and_raise(klass, message = nil)
      @e_klass   = klass
      @e_message = message
      self
    end

    def matches?(klass)
      return @matched unless @matched.nil?

      @klass = klass
      get_result_or_exception

      @matched = [:success, :failure, :exception].all? do |name|
        send("passes_#{name}").tap do |passed|
          @failed_name = name unless passed
        end
      end

      yield result, exception if @matched && block_given?

      @matched
    end

    def failure_message
      matched ? '' : failure_messages.join("\n  ")
    end

    private

    attr_reader :klass, :args, :exception, :result

    def get_result_or_exception
      @exception = nil
      @result    = klass.run(*args)
    rescue Exception => e
      @result    = nil
      @exception = e
    end

    def passes_success
      return true unless @s_message

      @result.present? &&
        @result.success? &&
        @result.message.to_s == @s_message.to_s
    end

    def passes_failure
      return true unless @f_code

      @result.present? &&
        @result.failure? &&
        @result.code == @f_code &&
        (@f_message.present? ? (@result.message.to_s == @f_message.to_s) : true)
    end

    def passes_exception
      return true unless @e_klass

      @exception.present? &&
        @exception.class == @e_klass &&
        (@e_message.present? ? (@exception.message == @e_message) : true)
    end

    def failure_messages
      messages = ["expected #{klass.name} to run with #{args.inspect}"]
      case failed_name
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
        messages << "but a #{@exception.class.name} exception with message #{@exception.message.inspect} was raised"
      else
        if @result.success?
          messages << 'and although it succeeded'
          messages << "the message was #{@result.message.to_s.inspect} instead of #{@s_message.to_s.inspect}" if @s_message.present? && @result.message.to_s != @s_message.to_s
        else
          messages << "and succeed with message #{@s_message.inspect}"
          messages << "but it failed with code :#{@result.code} and message #{@result.message.inspect}"
        end
      end
      messages
    end

    def failure_messages_for_failure
      messages = []
      if @exception.present?
        messages << "and fail with code :#{@f_code} and message #{@f_message.inspect}"
        messages << "but a #{@exception.class.name} exception with message #{@exception.message.inspect} was raised"
      else
        if @result.success?
          messages << "and fail with code :#{@f_code} and message #{@f_message.inspect}"
          messages << "but it succeeded with #{@result.message.inspect}"
        else
          messages << 'and although it failed'
          messages << "the code was :#{@result.code} instead of :#{@f_code}" if @result.code != @f_code
          messages << "the message was #{@result.message.to_s.inspect} instead of #{@f_message.to_s.inspect}" if @f_message.present? && @result.message.to_s != @f_message.to_s
        end
      end
      messages
    end

    def failure_messages_for_exception
      msg      = "and throw a #{@e_klass} exception"
      msg      += " with message #{@e_message.inspect}" if @e_message.present?
      messages = [msg]

      if @exception.nil?
        messages << 'but no exception was raised'
      else
        messages << 'and although an exception was raised'
        messages << "the class was #{@exception.class.name}" if @exception.class.name != @e_klass.name
        messages << "the message was #{@exception.message.inspect}" if @e_message.present? && @exception.message != @e_message
      end
      messages
    end

  end
end

RSpec.configure do |config|
  config.include Actionable::RspecMatchers
end
