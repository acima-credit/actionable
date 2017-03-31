module Actionable
  class Steps
    class Base
      attr_reader :name, :options

      def initialize(name, options = {})
        @name    = name.to_s
        @options = options
      end

      def run(_)
        return if skip?(instance)
      end

      private

      def skip?(instance)
        if @options[:if]
          !@options[:if].call(instance)
        elsif @options[:unless]
          @options[:unless].call(instance)
        else
          false
        end
      end
    end
  end
end
