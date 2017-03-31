module Actionable
  class Steps
    class Base
      attr_reader :name, :options

      def initialize(name, options = {})
        @name    = name.to_s
        @options = options
      end

      def run(_)
        raise "you must implement run() for #{self.class.name}"
      end
    end
  end
end
