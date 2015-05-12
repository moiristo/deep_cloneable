require 'rubygems'
require 'bundler/setup'
require 'appraisal'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "deep_cloneable"
    gem.summary = %Q{This gem gives every ActiveRecord::Base object the possibility to do a deep clone.}
    gem.description = %Q{Extends the functionality of ActiveRecord::Base#dup to perform a deep clone that includes user specified associations. }
    gem.email = "r.j.delange@nedforce.nl"
    gem.homepage = "http://github.com/moiristo/deep_cloneable"
    gem.authors = ["Reinier de Lange"]
    gem.license = "MIT"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "deep_cloneable #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
