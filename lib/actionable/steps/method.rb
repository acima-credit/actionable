# frozen_string_literal: true

module Actionable
  class Steps
    class Method < Base
      def run(instance)
        return [:skip, nil] if skip?(instance)

        instance.send name
        [instance.result&.code || :na, nil]
      end
    end
  end
end
