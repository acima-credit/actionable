module TestActionable

  class GreatAction < Actionable::Action

    set_model :invoice

    action :fail_for_2
    action :add_one
    action :add_two

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

    def self.human_attribute_name(attr, options = {})
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
