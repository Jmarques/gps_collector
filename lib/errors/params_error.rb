# frozen_string_literal: true

# Specialized errors
module Error
  # Error to handle invalid parameters
  class ParamsError < ArgumentError; end
end
