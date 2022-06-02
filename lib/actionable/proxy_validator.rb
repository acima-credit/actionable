# frozen_string_literal: true

module Actionable
  class ProxyValidator < SimpleDelegator
    include ActiveModel::Validations

    UniquenessValidator = ActiveRecord::Validations::UniquenessValidator

    class << self
      def default_model_name
        name.gsub(/Validator$/, '')
      end

      def model
        @model || default_model_name.constantize
      end

      def set_model(klass)
        @model = klass
      end

      def valid?(instance)
        new(instance).valid?
      end

      def method_missing(meth, *args, **kwargs, &block)
        if model.respond_to?(meth)
          model.__send__(meth, *args, **kwargs, &block)
        else
          super(meth, *args, **kwargs, &block)
        end
      end

      def respond_to_missing?(meth, include_private)
        model.respond_to?(meth, include_private) || super
      end
    end

    private

    def errors
      __getobj__.errors
    end
  end
end
