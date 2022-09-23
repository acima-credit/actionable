# frozen_string_literal: true

module Actionable
  class Failure < Result
    INVALID        = :invalid
    NOT_FOUND      = :not_found
    UNAUTHORIZED   = :unauthorized
    INTERNAL_ERROR = :internal_error

    def formatted_errors(join_str = ', ')
      return '' unless errors.present?
      return errors.full_messages.join join_str if errors.respond_to?(:full_messages)

      errors.inspect
    end
  end
end
