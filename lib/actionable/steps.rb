require 'actionable/steps/base'
require 'actionable/steps/method'
require 'actionable/steps/action'

module Actionable
  class Steps
    def self.build(name_or_class, options)
      case name_or_class
      when String, Symbol
        Method.new name_or_class, options
      else
        Action.new name_or_class, options
      end
    end
  end
end
