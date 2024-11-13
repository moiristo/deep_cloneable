# frozen_string_literal: true

$:.unshift File.expand_path('../lib', __FILE__)
require 'deep_cloneable/version'

Gem::Specification.new do |s|
  s.name = 'deep_cloneable'
  s.version = DeepCloneable::VERSION
  s.authors = ['Reinier de Lange']
  s.description = 'Extends the functionality of ActiveRecord::Base#dup to perform a deep clone that includes user specified associations.'
  s.summary = 'This gem gives every ActiveRecord::Base object the possibility to do a deep clone.'
  s.email = 'rjdelange@icloud.com'
  s.extra_rdoc_files = ['LICENSE']
  s.files = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.homepage = 'https://github.com/moiristo/deep_cloneable'
  s.licenses = ['MIT']
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.3'
  s.require_paths = ['lib']
  s.add_runtime_dependency('activerecord', ['>= 3.1.0', '< 9'])
end
