require 'rubygems'
require 'test/unit'
require 'pp'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Gem.activate 'activerecord'
require 'active_record'
require File.dirname(__FILE__) + '/../init.rb'

module Animal
  class Human < ActiveRecord::Base
    has_many :pigs
    
    has_many :ownerships    
    has_many :chickens, :through => :ownerships
  end
  class Pig < ActiveRecord::Base
    belongs_to :human
  end
      
  class Chicken < ActiveRecord::Base
    has_many :ownerships
    has_many :humans, :through => :ownerships
  end  
  
  class Ownership < ActiveRecord::Base
    belongs_to :human
    belongs_to :chicken
    
    validates_uniqueness_of :chicken_id, :scope => :human_id
  end  
end

class GoldPiece < ActiveRecord::Base;   belongs_to :treasure  end
class Matey < ActiveRecord::Base;       belongs_to :pirate    end
class Parrot < ActiveRecord::Base;      belongs_to :pirate    end
class BattleShip < ActiveRecord::Base;  has_many   :pirates, :as => :ship end

class Pirate < ActiveRecord::Base
  belongs_to :ship, :polymorphic => true

  has_many :mateys
  has_many :treasures, :foreign_key => 'owner'
  has_many :gold_pieces, :through => :treasures
  has_one :parrot
end

class Treasure < ActiveRecord::Base
  belongs_to :pirate, :foreign_key => :owner
  belongs_to :matey
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