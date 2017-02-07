module Actionable
  class Failure < Result

    def formatted_errors(join_str = ', ')
      return '' unless errors.present?

      errors.full_messages.join join_str
    end

  end
end