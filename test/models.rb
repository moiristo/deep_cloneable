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
class Parrot < ActiveRecord::Base;      belongs_to :pirate; attr_accessor :cloned_from_id end
class BattleShip < ActiveRecord::Base;  has_many   :pirates, :as => :ship end

class Pirate < ActiveRecord::Base
  belongs_to :ship, :polymorphic => true

  has_many :mateys
  has_many :treasures, :foreign_key => 'owner'
  has_many :gold_pieces, :through => :treasures
  has_one :parrot

  attr_accessor :cloned_from_id
end

class Treasure < ActiveRecord::Base
  belongs_to :pirate, :foreign_key => :owner
  belongs_to :matey
  has_many :gold_pieces
end

class Person < ActiveRecord::Base
  has_and_belongs_to_many :cars
end

class Car < ActiveRecord::Base
  has_and_belongs_to_many :people
end

class ChildWithValidation < ActiveRecord::Base
  belongs_to :parent, :class_name => 'ParentWithValidation'
  validates :name, :presence => true
end

class ParentWithValidation < ActiveRecord::Base
  has_many :children, :class_name => 'ChildWithValidation'
  validates :name, :presence => true
end

class Part < ActiveRecord::Base
  has_many :child_parts, :class_name => 'Part', :foreign_key => 'parent_part_id'
end
