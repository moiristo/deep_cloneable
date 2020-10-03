# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'deep_cloneable'
  s.version = '3.0.0'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.require_paths = ['lib']
  s.authors = ['Reinier de Lange']
  s.date = '2019-08-18'
  s.description = 'Extends the functionality of ActiveRecord::Base#dup to perform a deep clone that includes user specified associations. '
  s.email = 'rjdelange@icloud.com'
  s.extra_rdoc_files = [
    'LICENSE'
  ]
  s.files = [
    '.document',
    '.rubocop.yml',
    '.travis.yml',
    'Appraisals',
    'CHANGELOG.md',
    'Gemfile',
    'Gemfile.lock',
    'LICENSE',
    'Rakefile',
    'VERSION',
    'deep_cloneable.gemspec',
    'gemfiles/3.1.gemfile',
    'gemfiles/3.1.gemfile.lock',
    'gemfiles/3.2.gemfile',
    'gemfiles/3.2.gemfile.lock',
    'gemfiles/4.0.gemfile',
    'gemfiles/4.0.gemfile.lock',
    'gemfiles/4.1.gemfile',
    'gemfiles/4.1.gemfile.lock',
    'gemfiles/4.2.gemfile',
    'gemfiles/4.2.gemfile.lock',
    'gemfiles/5.0.gemfile',
    'gemfiles/5.0.gemfile.lock',
    'gemfiles/5.1.gemfile',
    'gemfiles/5.1.gemfile.lock',
    'gemfiles/5.2.gemfile',
    'gemfiles/5.2.gemfile.lock',
    'gemfiles/6.0.gemfile',
    'gemfiles/6.0.gemfile.lock',
    'init.rb',
    'lib/deep_cloneable.rb',
    'lib/deep_cloneable/association_not_found_exception.rb',
    'lib/deep_cloneable/deep_clone.rb',
    'lib/deep_cloneable/skip_validations.rb',
    'readme.md',
    'test/database.yml',
    'test/models.rb',
    'test/schema.rb',
    'test/test_deep_cloneable.rb',
    'test/test_helper.rb'
  ]
  s.homepage = 'https://github.com/moiristo/deep_cloneable'
  s.licenses = ['MIT']
  s.rubygems_version = '3.0.2'
  s.summary = 'This gem gives every ActiveRecord::Base object the possibility to do a deep clone.'

  if s.respond_to? :specification_version
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency('activerecord', ['>= 3.1.0', '< 7'])
    else
      s.add_dependency('activerecord', ['>= 3.1.0', '< 7'])
    end
  else
    s.add_dependency('activerecord', ['>= 3.1.0', '< 7'])
  end
end
