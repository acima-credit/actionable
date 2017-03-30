require 'actionable/steps/base'
require 'actionable/steps/method'

module Actionable
  class Steps
    def self.build(name, options)
      Method.new name, options
    end
  end
end
