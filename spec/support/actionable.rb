# frozen_string_literal: true

module TestActionable
  def self.logger
    @logger ||= Logger.new(STDOUT).tap { |x| x.level = Logger::FATAL }
  end

  module Helpers
    def expect_logs(meth, *lines)
      lines.each do |line|
        expect(TestActionable.logger).to receive(meth).with(line)
      end
    end
  end

  class BaseAction < Actionable::Action
    set_model :invoice

    attr_reader :number

    def initialize(number)
      super()
      @number = number
      log_action '@number = %i', @number
    end

    def fail_for_2
      return unless @number == 2

      log_action 'failing for 2 ...'
      fail :bad_number, 'Wrong number'
    end

    def fail_on_six
      return unless @number == 6

      log_action 'failing for 6 ...'
      fail :bad_number, 'Six is always wrong', a: 1
    end

    def add_one
      log_action '%i + %i = %i', @number, 1, @number + 1
      @number += 1
    end

    def add_two
      log_action '%i + %i = %i', @number, 2, @number + 2
      @number += 2
    end

    def add_three
      log_action '%i + %i = %i', @number, 3, @number + 3
      @number += 3
    end

    def add_five
      log_action '%i + %i = %i', @number, 5, @number + 5
      @number += 5
    end

    def add_ten
      log_action '%i + %i = %i', @number, 10, @number + 10
      @number += 10
    end

    def odd?
      log_action 'res : %s', @number.odd?
      @number.odd?
    end

    def is_three?
      log_action 'res : %s', @number == 3
      @number == 3
    end
  end

  class GreatAction < BaseAction
    measure :all
    step :fail_for_2
    step :add_one
    step :add_two
  end

  class AddTwo < BaseAction
    step :add_two
  end

  class SmallAction < BaseAction
    measure :all
    action :fail_on_six
    action :add_three
  end

  class ComposedAction < BaseAction
    measure :all
    step SmallAction, params: [:number]
    step :add_five
  end

  class FailOnAddAction < BaseAction
    action :add_three
    action :fail_on_six
  end

  class ComposedConditionalAction < BaseAction
    step FailOnAddAction, params: [:number], if: :odd?
    step :add_five
  end

  class OverComposedAction < BaseAction
    step :add_five
    step ComposedAction, params: [:number]
    step :add_ten
  end

  class ExtraComposedAction < BaseAction
    step :add_three
    step :add_extra

    def add_extra
      @extra_one = true
      @extra_two = true
    end
  end

  class ControlledComposedAction < BaseAction
    step :add_one
    step ExtraComposedAction, params: [:number], fixtures: %i[number extra_one]
  end

  class ConditionalAction < BaseAction
    step :add_one, if: lambda { |x| x.number == 1 }
    step :add_three, unless: :is_three?
  end

  class CaseAction < BaseAction
    case_step :number do
      on 1, :add_one
      on 2, TestActionable::AddTwo, params: [:number]
      default :add_three
    end
  end

  class FinalAction < BaseAction
    step :add_one
    step :fail_for_2
    on_success :add_two
    on_failure :add_three
    always :add_five
  end

  class BangAction < BaseAction
    step :fail_for_x
    step :succeed_for_y
    step :ok_for_others

    def initialize(letter)
      @letter = letter.to_s.downcase
      @final  = "[#{@letter}]"
    end

    def fail_for_x
      fail! :bad_x, 'not x' if @letter == 'x'

      @final += ' > x'
    end

    def succeed_for_y
      succeed! :good_y, 'yes y' if @letter == 'y'

      @final += ' > y'
    end

    def ok_for_others
      @final += ' > ok'
    end
  end

  class LoggingAction < BaseAction
    action_logger TestActionable.logger
    action_logger_severity :info

    step :add_one
    step :add_two
  end

  class Post
    extend ActiveModel::Naming

    attr_reader :errors
    attr_accessor :title, :author, :publication_date

    def initialize(options = {})
      @errors = ActiveModel::Errors.new(self)
      options.each { |k, v| send "#{k}=", v }
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.human_attribute_name(attr, _options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end

    def self.extra
      true
    end

    def to_s
      %(#<#{self.class.name} title=#{title.inspect} author=#{author.inspect} ) +
        %(publication_date=#{publication_date.inspect}>)
    end

    alias inspect to_s
  end

  class PostValidator < Actionable::ProxyValidator
    validates :title, presence: true
    validates :author, presence: true
    validates :publication_date, presence: true
  end

  class BadPost
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def self.extra
      false
    end
  end

  class WrongPostValidator < Actionable::ProxyValidator
    set_model BadPost
  end
end

RSpec.configure do |config|
  config.include TestActionable::Helpers
end
