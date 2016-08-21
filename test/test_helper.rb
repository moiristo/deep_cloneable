require 'rubygems'
require 'yaml'
require 'sqlite3'

gem 'minitest'
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record'

I18n.enforce_available_locales = true

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))

  if defined?(ActiveSupport::BufferedLogger)
    ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")
  else
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(File.dirname(__FILE__) + "/debug.log")
  end

  db_adapter = ENV['DB']
  db_adapter ||= 'sqlite3'

  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end
  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/schema.rb")
end

load_schema
require File.dirname(__FILE__) + '/../init.rb'
require 'models'