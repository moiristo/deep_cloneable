require 'rubygems'
require 'test/unit'
require 'pp'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Gem.activate 'activerecord'
require 'active_record'
require 'active_record/fixtures'
require File.dirname(__FILE__) + '/../init.rb'

class GoldPiece < ActiveRecord::Base; belongs_to :treasure end
class Matey < ActiveRecord::Base; belongs_to :pirate end
class Parrot < ActiveRecord::Base; belongs_to :pirate end

class Pirate < ActiveRecord::Base
  has_many :mateys
  has_many :treasures
  has_many :gold_pieces, :through => :treasures
  has_one :parrot
end

class Treasure < ActiveRecord::Base
  belongs_to :pirate  
  has_many :gold_pieces
end

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")
  db_adapter = ENV['DB']
  # no db passed, try one of these fine config-free DBs before bombing.
  db_adapter ||= begin
    require 'rubygems'
    require 'sqlite'
    'sqlite'
  rescue MissingSourceFile
    begin
      require 'sqlite3'
      'sqlite3'
    rescue MissingSourceFile
    end
  end

  if db_adapter.nil?
    raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
  end
  ActiveRecord::Base.establish_connection(config[db_adapter])
  load(File.dirname(__FILE__) + "/schema.rb")
end 