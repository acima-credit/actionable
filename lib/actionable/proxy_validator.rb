require 'delegate'
require 'active_model'

module Actionable
  class ProxyValidator < SimpleDelegator

    include ActiveModel::Validations

    def self.valid?(instance)
      new(instance).valid?
    end

    private

    def errors
      __getobj__.errors
    end

  end
end