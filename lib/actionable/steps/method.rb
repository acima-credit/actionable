module Actionable
  class Steps
    class Method < Base
      def run(instance)
        return if skip?(instance)

        instance.send name
      end
    end
  end
end
