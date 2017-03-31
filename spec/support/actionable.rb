module TestActionable
  class GreatAction < Actionable::Action
    set_model :invoice

    action :fail_for_2
    step :add_one
    step :add_two

    def initialize(number)
      super()
      @number = number
    end

    def add_one
      @number += 1
    end

    def fail_for_2
      fail :bad_number, 'Wrong number' if @number == 2
    end

    def add_two
      @number += 2
    end
  end

  class SmallAction < Actionable::Action
    set_model :invoice

    step :fail_on_six
    step :add_three

    def initialize(number)
      super()
      @number = number
    end

    def fail_on_six
      fail :bad_number, 'Six is always wrong', a: 1 if @number == 6
    end

    def add_three
      @number += 3
    end
  end

  class ComposedAction < Actionable::Action
    set_model :invoice

    step SmallAction, params: [:number]
    step :add_five

    def initialize(number)
      super()
      @number = number
    end

    def fail_on_six
      fail :bad_number, 'Six is always wrong', a: 1 if @number == 6
    end

    def add_five
      @number += 5
    end
  end

  class OverComposedAction < Actionable::Action
    set_model :invoice

    step :add_five
    step ComposedAction, params: [:number]
    step :add_ten

    def initialize(number)
      super()
      @number = number
    end

    def add_five
      @number += 5
    end

    def add_ten
      @number += 10
    end
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
