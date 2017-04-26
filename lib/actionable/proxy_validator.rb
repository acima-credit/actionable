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

      def method_missing(m, *args, &block)
        if model.respond_to?(m)
          model.__send__(m, *args, &block)
        else
          super(m, *args, &block)
        end
      end

      def respond_to_missing?(m, include_private)
        model.respond_to?(m, include_private) || super
      end
    end

    private

    def errors
      __getobj__.errors
    end
  end
end
