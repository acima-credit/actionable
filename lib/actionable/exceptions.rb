# frozen_string_literal: true

module Actionable
  class SkippableError < StandardError
  end

  class SuccessError < SkippableError
  end

  class FailureError < SkippableError
  end
end
