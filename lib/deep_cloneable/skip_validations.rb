# frozen_string_literal: true

module DeepCloneable
  module SkipValidations
    def perform_validations(options = {})
      options[:validate] = false
      super(options)
    end
  end
end
