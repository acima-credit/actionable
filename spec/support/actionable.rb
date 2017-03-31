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

  class ConditionalAction < BaseAction
    step :add_one, if: lambda { |x| x.number == 1 }
    step :add_three, unless: lambda { |x| x.number == 3 }
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
  end

  class PostValidator < Actionable::ProxyValidator
    validates :title, presence: true
    validates :author, presence: true
    validates :publication_date, presence: true
  end
end
