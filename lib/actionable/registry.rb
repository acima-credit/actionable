# frozen_string_literal: true

module Actionable
  class Registry
    def initialize
      @list = {}
    end

    delegate :keys, :values, :size, :empty?, :[], to: :@list

    def add(action_class)
      @list[action_class.name] = action_class
    end
  end

  def self.registry
    @registry ||= Registry.new
  end
end
