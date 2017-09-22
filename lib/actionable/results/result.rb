module Actionable
  class Result
    attr_reader :code, :message, :errors, :fixtures

    def initialize(fields = {})
      @code         = (fields[:code] || default_code).to_sym
      @message      = (fields[:message] || '').to_s
      self.errors   = fields[:errors]
      self.fixtures = (fields[:fixtures] || {}).to_hash
    end

    def default_code
      self.class.name.split('::').last.underscore.to_sym
    end

    def success?
      code == :success
    end

    alias successful? success?

    def failure?
      !success?
    end

    alias failed? failure?

    def errors=(value)
      @errors = indifferent_value value
    end

    def fixtures=(value)
      @fixtures = indifferent_value value
    end

    def respond_to?(method, _ = false)
      (fixtures && fixtures.key?(method)) || super
    end

    def method_missing(method, *_, &blk)
      return super unless fixtures && fixtures.key?(method)

      fixtures[method]
    end

    def to_s
      "#<#{self.class.name} " \
        "code=#{code.inspect}, " \
        "message=#{message.inspect}, " \
        "errors=#{errors.inspect}, " \
        "fixtures=#{fixtures.keys.sort.inspect}" \
        '>'
    end

    alias inspect to_s

    private

    def indifferent_value(value)
      if value.respond_to?(:with_indifferent_access)
        value.with_indifferent_access
      else
        value
      end
    end
  end
end
