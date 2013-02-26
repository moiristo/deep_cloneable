require File.dirname(__FILE__) + '/test_helper'

class TestDeepCloneable < Test::Unit::TestCase
  load_schema

  @@clone_method = ActiveRecord::VERSION::MAJOR >= 3 && ActiveRecord::VERSION::MINOR > 0 ? :dup : :clone

  def setup
    @jack  = Pirate.create(:name => 'Jack Sparrow', :nick_name => 'Captain Jack', :age => 30)
    @polly = Parrot.create(:name => 'Polly', :pirate => @jack)
    @john = Matey.create(:name => 'John', :pirate => @jack)
    @treasure = Treasure.create(:found_at => 'Isla del Muerte', :pirate => @jack, :matey => @john)
    @gold_piece = GoldPiece.create(:treasure => @treasure)
    @ship = BattleShip.create(:name => 'Black Pearl', :pirates => [@jack])
  end

  def test_single_dup_exception
    dup = @jack.send(@@clone_method, :except => :name)
    assert dup.new_record?
    assert dup.save
    assert_equal @jack.name, @jack.send(@@clone_method).name # Old behaviour
    assert_nil dup.name
    assert_equal @jack.nick_name, dup.nick_name
  end

  def test_multiple_dup_exception
    dup = @jack.send(@@clone_method, :except => [:name, :nick_name])
    assert dup.new_record?
    assert dup.save
    assert_nil dup.name
    assert_equal 'no nickname', dup.nick_name
    assert_equal @jack.age, dup.age
  end

  def test_single_include_association
    dup = @jack.send(@@clone_method, :include => :mateys)
    assert dup.new_record?
    assert dup.save
    assert_equal 1, dup.mateys.size
  end

  def test_single_include_belongs_to_polymorphic_association
    dup = @jack.send(@@clone_method, :include => :ship)
    assert dup.new_record?
    assert dup.save
    assert_not_nil dup.ship
    assert_not_equal @jack.ship, dup.ship
  end

  def test_single_include_has_many_polymorphic_association
    dup = @ship.send(@@clone_method, :include => :pirates)
    assert dup.new_record?
    assert dup.save
    assert dup.pirates.any?
  end

  def test_multiple_include_association
    dup = @jack.send(@@clone_method, :include => [:mateys, :treasures])
    assert dup.new_record?
    assert dup.save
    assert_equal 1, dup.mateys.size
    assert_equal 1, dup.treasures.size
  end

  def test_deep_include_association
    dup = @jack.send(@@clone_method, :include => {:treasures => :gold_pieces})
    assert dup.new_record?
    assert dup.save
    assert_equal 1, dup.treasures.size
    assert_equal 1, dup.gold_pieces.size
  end

  def test_include_association_assignments
    dup = @jack.send(@@clone_method, :include => :treasures)
    assert dup.new_record?

    dup.treasures.each do |treasure|
      assert_equal dup, treasure.pirate
    end
  end

  def test_multiple_and_deep_include_association
    dup = @jack.send(@@clone_method, :include => {:treasures => :gold_pieces, :mateys => {}})
    assert dup.new_record?
    assert dup.save
    assert_equal 1, dup.treasures.size
    assert_equal 1, dup.gold_pieces.size
    assert_equal 1, dup.mateys.size
  end

  def test_multiple_and_deep_include_association_with_array
    dup = @jack.send(@@clone_method, :include => [{:treasures => :gold_pieces}, :mateys])
    assert dup.new_record?
    assert dup.save
    assert_equal 1, dup.treasures.size
    assert_equal 1, dup.gold_pieces.size
    assert_equal 1, dup.mateys.size
  end

  def test_with_belongs_to_relation
    dup = @jack.send(@@clone_method, :include => :parrot)
    assert dup.new_record?
    assert dup.save
    assert_not_equal dup.parrot, @jack.parrot
  end

  def test_should_pass_nested_exceptions
    dup = @jack.send(@@clone_method, :include => :parrot, :except => [:name, { :parrot => [:name] }])
    assert dup.new_record?
    assert dup.save
    assert_not_equal dup.parrot, @jack.parrot
    assert_not_nil @jack.parrot.name
    assert_nil dup.parrot.name
  end

  def test_should_not_double_dup_when_using_dictionary
    current_matey_count = Matey.count
    dup = @jack.send(@@clone_method, :include => [:mateys, { :treasures => :matey }], :use_dictionary => true)
    assert dup.new_record?
    dup.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_not_double_dup_when_using_manual_dictionary
    current_matey_count = Matey.count

    dict = { :mateys => {} }
    @jack.mateys.each{|m| dict[:mateys][m] = m.send(@@clone_method) }

    dup = @jack.send(@@clone_method, :include => [:mateys, { :treasures => :matey }], :dictionary => dict)
    assert dup.new_record?
    dup.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_support_ar_class_under_module
    @human = Animal::Human.create :name => "Michael"
    @pig = Animal::Pig.create :human => @human, :name => 'big pig'

    dup_human = @human.send(@@clone_method, :include => [:pigs])
    assert dup_human.new_record?
    assert dup_human.save
    assert_equal 1, dup_human.pigs.count

    @human2 = Animal::Human.create :name => "John"
    @pig2 = @human2.pigs.create :name => 'small pig'

    dup_human_2 = @human.send(@@clone_method, :include => [:pigs])
    assert dup_human_2.new_record?
    assert dup_human_2.save
    assert_equal 1, dup_human_2.pigs.count
  end

  def test_should_dup_many_to_many_associations
    @human = Animal::Human.create :name => "Michael"
    @human2 = Animal::Human.create :name => "Jack"
    @chicken1 = Animal::Chicken.create :name => 'Chick1'
    @chicken2 = Animal::Chicken.create :name => 'Chick2'
    @human.chickens << [@chicken1, @chicken2]
    @human2.chickens << [@chicken1, @chicken2]

    dup_human = @human.send(@@clone_method, :include => :ownerships)
    assert dup_human.new_record?
    assert dup_human.save
    assert_equal 2, dup_human.chickens.count
  end

  def test_should_dup_with_block
    dup = @jack.send(@@clone_method, :include => :parrot) do |original, kopy|
      kopy.cloned_from_id = original.id
    end

    assert dup.new_record?
    assert dup.save
    assert_equal @jack.id, dup.cloned_from_id
    assert_equal @jack.parrot.id, dup.parrot.cloned_from_id
  end

  def test_should_dup_habtm_associations
    @person1 = Person.create :name => "Bill"
    @person2 = Person.create :name => "Ted"
    @car1 = Car.create :name => 'Mustang'
    @car2 = Car.create :name => 'Camaro'
    @person1.cars << [@car1, @car2]
    @person2.cars << [@car1, @car2]

    dup_person = @person1.dup :include => :cars

    assert dup_person.new_record?
    assert_equal [@person1, @person2, dup_person], @car1.people
    assert_equal [@person1, @person2, dup_person], @car2.people

    assert dup_person.save

    # did NOT dup the Car instances
    assert_equal 2, Car.all.count

    # did dup the correct join table rows
    assert_equal @person1.cars, dup_person.cars
    assert_equal 2, dup_person.cars.count
  end

  def test_parent_validations_run_on_save_after_clone
    child = ChildWithValidation.create :name => 'Jimmy'
    parent = ParentWithValidation.new :children => [child]
    parent.save :validate => false

    dup_parent = parent.dup :include => :children

    assert !dup_parent.save
    assert dup_parent.new_record?
    assert !dup_parent.valid?
    assert dup_parent.children.first.valid?
    assert_equal dup_parent.errors.messages, :name => ["can't be blank"]
  end

  def test_parent_validations_dont_run_on_save_after_clone
    child = ChildWithValidation.create :name => 'Jimmy'
    parent = ParentWithValidation.new :children => [child]
    parent.save :validate => false

    dup_parent = parent.dup :include => :children, :validate => false

    assert dup_parent.save
    assert !dup_parent.new_record?
    assert !dup_parent.valid?
    assert dup_parent.children.first.valid?
    assert_equal dup_parent.errors.messages, :name => ["can't be blank"]
  end

  def test_child_validations_run_on_save_after_clone
    child = ChildWithValidation.new
    child.save :validate => false
    parent = ParentWithValidation.create :name => 'John', :children => [child]

    dup_parent = parent.dup :include => :children

    assert !dup_parent.save
    assert dup_parent.new_record?
    assert !dup_parent.valid?
    assert !dup_parent.children.first.valid?
    assert_equal dup_parent.errors.messages, :children => ["is invalid"]
  end

  def test_child_validations_run_on_save_after_clone
    child = ChildWithValidation.new
    child.save :validate => false
    parent = ParentWithValidation.create :name => 'John', :children => [child]

    dup_parent = parent.dup :include => :children, :validate => false

    assert dup_parent.save
    assert !dup_parent.new_record?
    assert !dup_parent.valid?
    assert !dup_parent.children.first.valid?
    assert_equal dup_parent.errors.messages, :children => ["is invalid"]
  end

end
