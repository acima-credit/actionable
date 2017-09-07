module TestActionable
  class BaseAction < Actionable::Action
    set_model :invoice

    attr_reader :number

    def initialize(number)
      super()
      @number = number
    end

    def fail_for_2
      fail :bad_number, 'Wrong number' if @number == 2
    end

    def fail_on_six
      fail :bad_number, 'Six is always wrong', a: 1 if @number == 6
    end

    def add_one
      @number += 1
    end

    def add_two
      @number += 2
    end

    def add_three
      @number += 3
    end

    def add_four
      @number += 4
    end

    def add_five
      @number += 5
    end

    def add_ten
      @number += 10
    end
  end

  class GreatAction < BaseAction
    step :fail_for_2
    step :add_one
    step :add_two
  end

  class AddTwo < BaseAction
    step :add_two
  end

  class SmallAction < BaseAction
    action :fail_on_six
    action :add_three
  end

  class ComposedAction < BaseAction
    step SmallAction, params: [:number]
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
    step ExtraComposedAction, params: [:number], fixtures: [:number, :extra_one]
  end

  class ConditionalAction < BaseAction
    step :add_one, if: lambda { |x| x.number == 1 }
    step :add_three, unless: :is_three

    def is_three
      number == 3
    end
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
