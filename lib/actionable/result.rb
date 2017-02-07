module Actionable
  class Result

    include Virtus.value_object

    attribute :code, Symbol, default: :default_code
    attribute :message, String, default: ''
    attribute :errors, Object
    attribute :fixtures, Object, default: {}

    def default_code
      self.class.name.split('::').last.underscore.to_sym
    end

    def success?
      code == :success
    end

    alias :successful? :success?

    def failure?
      !success?
    end

    alias :failed? :failure?

    def errors=(value)
      value = value.with_indifferent_access if value.respond_to?(:with_indifferent_access)
      super value
    end

    def fixtures=(value)
      super value.to_hash.with_indifferent_access
    end

    def to_s
      "#<#{self.class.name} " +
        "code=#{code.inspect}, " +
        "message=#{message.inspect}, " +
        "errors=#{errors.inspect}, " +
        "fixtures=#{fixtures.keys.sort.inspect}" +
        '>'
    end

    alias :inspect :to_s

    def respond_to?(method, include_private = false)
      (fixtures && fixtures.key?(method)) || super
    end

    def method_missing(method, *args, &block)
      return super unless fixtures.key?(method)

      fixtures[method]
    end

  end
end