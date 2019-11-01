# frozen_string_literal: true

module Actionable
  class Steps
    class Method < Base
      def run(instance)
        return :skip if skip?(instance)

        instance.send name
        instance.result&.code || :na
      end
    end
  end
end
