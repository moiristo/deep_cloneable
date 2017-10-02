module Animal
  class Human < ActiveRecord::Base
    has_many :pigs

    has_many :ownerships
    has_many :chickens, :through => :ownerships
  end

  class Pig < ActiveRecord::Base
    belongs_to :human
  end

  class Bird < ActiveRecord::Base
    belongs_to :planet
  end

  class Chicken < Bird
    has_many :ownerships
    has_many :humans, :through => :ownerships
  end

  class Dove < Bird
  end

  class Planet < ActiveRecord::Base
    has_many :birds
  end


  class Ownership < ActiveRecord::Base
    belongs_to :human
    belongs_to :chicken

    validates_uniqueness_of :chicken_id, :scope => :human_id
  end

end

class GoldPiece < ActiveRecord::Base;   belongs_to :treasure  end
class Matey < ActiveRecord::Base;       belongs_to :pirate    end
class BattleShip < ActiveRecord::Base;  has_many   :pirates, :as => :ship end

class Parrot < ActiveRecord::Base
  belongs_to :pirate
  has_many :parrot_cages, :foreign_key => :owner_id, :inverse_of => :parrot, :class_name => 'Cage'
  attr_accessor :cloned_from_id
end

class Cage < ActiveRecord::Base
  belongs_to :parrot, :foreign_key => :owner_id, :inverse_of => :parrot_cages
  belongs_to :pirate, :foreign_key => :owner_id, :inverse_of => :pirate_cages
end

class Pirate < ActiveRecord::Base
  belongs_to :ship, :polymorphic => true

  has_many :mateys
  has_many :treasures, :foreign_key => 'owner'
  has_many :gold_pieces, :through => :treasures
  has_one :parrot
  has_many :pirate_cages, :inverse_of => :pirate, :foreign_key => :owner_id, :class_name => 'Cage'

  serialize :piastres

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

class Coin < ActiveRecord::Base
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
  # belongs_to :parent_part, :class_name => 'Part'
  has_many :child_parts, :class_name => 'Part', :foreign_key => 'parent_part_id'
end

class Student < ActiveRecord::Base
  has_many :student_assignments, :dependent => :destroy
  has_many :subjects, :through => :student_assignments
end

class Subject < ActiveRecord::Base
  has_many :student_assignments, :dependent => :destroy
  has_many :students, :through => :student_assignments
end

class StudentAssignment < ActiveRecord::Base
  belongs_to :subject
  belongs_to :student
end

class Building < ActiveRecord::Base
  has_many :apartments
  has_many :contractors
end

class Apartment < ActiveRecord::Base
  belongs_to :building
  has_and_belongs_to_many :contractors
end

class Contractor < ActiveRecord::Base
  belongs_to :building
  has_and_belongs_to_many :apartments
end

class User < ActiveRecord::Base
  has_many :orders
end

class Order < ActiveRecord::Base
  belongs_to :user
  has_many :products
end

class Product < ActiveRecord::Base
  belongs_to :order
end
