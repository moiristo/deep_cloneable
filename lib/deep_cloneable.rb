# frozen_string_literal: true

require 'active_record'
require 'active_support/lazy_load_hooks'
require 'active_support/core_ext/array/wrap'

require 'deep_cloneable/association_not_found_exception'
require 'deep_cloneable/skip_validations'
require 'deep_cloneable/deep_clone'

module DeepCloneable
end

ActiveSupport.on_load :active_record do
  protected :initialize_dup if ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 1

  include DeepCloneable::DeepClone
end
