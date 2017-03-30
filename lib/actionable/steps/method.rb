module Actionable
  class Steps
    class Method < Base

      def run(instance)
        instance.send name
      end

    end
  end
end
