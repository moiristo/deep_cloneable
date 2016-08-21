require 'test_helper'

class TestDeepCloneable < MiniTest::Unit::TestCase

  def setup
    @jack  = Pirate.create(:name => 'Jack Sparrow', :nick_name => 'Captain Jack', :age => 30)
    @polly = Parrot.create(:name => 'Polly', :age => 2, :pirate => @jack)
    @john = Matey.create(:name => 'John', :pirate => @jack)
    @treasure = Treasure.create(:found_at => 'Isla del Muerte', :pirate => @jack, :matey => @john)
    @gold_piece = GoldPiece.create(:treasure => @treasure)
    @ship = BattleShip.create(:name => 'Black Pearl', :pirates => [@jack])
  end

  def test_single_deep_clone_exception
    deep_clone = @jack.deep_clone(:except => :name)
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal @jack.name, @jack.deep_clone.name
    assert_nil deep_clone.name
    assert_equal @jack.nick_name, deep_clone.nick_name
  end

  def test_multiple_deep_clone_exception
    deep_clone = @jack.deep_clone(:except => [:name, :nick_name])
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_nil deep_clone.name
    assert_equal 'no nickname', deep_clone.nick_name
    assert_equal @jack.age, deep_clone.age
  end

  def test_single_deep_clone_onliness
    deep_clone = @jack.deep_clone(:only => :name)
    assert deep_clone.new_record?
    assert deep_clone.piastres, []
    assert deep_clone.save
    assert_equal @jack.name, deep_clone.name
    assert_equal 'no nickname', deep_clone.nick_name
    assert_nil deep_clone.age
    assert_nil deep_clone.ship_id
    assert_nil deep_clone.ship_type
  end

  def test_multiple_deep_clone_onliness
    deep_clone = @jack.deep_clone(:only => [:name, :nick_name])
    assert deep_clone.new_record?
    assert deep_clone.piastres, []
    assert deep_clone.save
    assert_equal @jack.name, deep_clone.name
    assert_equal @jack.nick_name, deep_clone.nick_name
    assert_nil deep_clone.age
    assert_nil deep_clone.ship_id
    assert_nil deep_clone.ship_type
  end

  def test_single_include_association
    deep_clone = @jack.deep_clone(:include => :mateys)
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.mateys.size
  end

  def test_single_include_belongs_to_polymorphic_association
    deep_clone = @jack.deep_clone(:include => :ship)
    assert deep_clone.new_record?
    assert deep_clone.save
    refute_nil deep_clone.ship
    refute_equal @jack.ship, deep_clone.ship
  end

  def test_single_include_has_many_polymorphic_association
    deep_clone = @ship.deep_clone(:include => :pirates)
    assert deep_clone.new_record?
    assert deep_clone.save
    assert deep_clone.pirates.any?
  end

  def test_multiple_include_association
    deep_clone = @jack.deep_clone(:include => [:mateys, :treasures])
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.mateys.size
    assert_equal 1, deep_clone.treasures.size
  end

  def test_deep_include_association
    deep_clone = @jack.deep_clone(:include => {:treasures => :gold_pieces})
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.treasures.size
    assert_equal 1, deep_clone.gold_pieces.size
  end

  def test_include_association_assignments
    deep_clone = @jack.deep_clone(:include => :treasures)
    assert deep_clone.new_record?

    deep_clone.treasures.each do |treasure|
      assert_equal deep_clone, treasure.pirate
    end
  end

  def test_multiple_and_deep_include_association
    deep_clone = @jack.deep_clone(:include => {:treasures => :gold_pieces, :mateys => {}})
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.treasures.size
    assert_equal 1, deep_clone.gold_pieces.size
    assert_equal 1, deep_clone.mateys.size
  end

  def test_multiple_and_deep_include_association_with_array
    deep_clone = @jack.deep_clone(:include => [{:treasures => :gold_pieces}, :mateys])
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.treasures.size
    assert_equal 1, deep_clone.gold_pieces.size
    assert_equal 1, deep_clone.mateys.size
  end

  def test_with_belongs_to_relation
    deep_clone = @jack.deep_clone(:include => :parrot)
    assert deep_clone.new_record?
    assert deep_clone.save
    refute_equal deep_clone.parrot, @jack.parrot
  end

  def test_should_pass_nested_exceptions
    deep_clone = @jack.deep_clone(:include => :parrot, :except => [:name, { :parrot => [:name] }])
    assert deep_clone.new_record?
    assert deep_clone.save
    refute_equal deep_clone.parrot, @jack.parrot
    assert_equal deep_clone.parrot.age, @jack.parrot.age
    refute_nil @jack.parrot.name
    assert_nil deep_clone.parrot.name
  end

  def test_should_pass_nested_onlinesses
    deep_clone = @jack.deep_clone(:include => :parrot, :only => [:name, { :parrot => [:name] }])
    assert deep_clone.new_record?
    assert deep_clone.piastres, []
    assert deep_clone.save
    refute_equal deep_clone.parrot, @jack.parrot
    assert_equal deep_clone.parrot.name, @jack.parrot.name
    assert_nil deep_clone.parrot.age
  end

  def test_should_not_double_deep_clone_when_using_dictionary
    current_matey_count = Matey.count
    deep_clone = @jack.deep_clone(:include => [:mateys, { :treasures => :matey }], :use_dictionary => true)
    assert deep_clone.new_record?
    deep_clone.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_not_double_deep_clone_when_using_manual_dictionary
    current_matey_count = Matey.count

    dict = { :mateys => {} }
    @jack.mateys.each{|m| dict[:mateys][m] = m.deep_clone }

    deep_clone = @jack.deep_clone(:include => [:mateys, { :treasures => :matey }], :dictionary => dict)
    assert deep_clone.new_record?
    deep_clone.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_support_ar_class_under_module
    @human = Animal::Human.create :name => "Michael"
    @pig = Animal::Pig.create :human => @human, :name => 'big pig'

    deep_clone_human = @human.deep_clone(:include => [:pigs])
    assert deep_clone_human.new_record?
    assert deep_clone_human.save
    assert_equal 1, deep_clone_human.pigs.count

    @human2 = Animal::Human.create :name => "John"
    @pig2 = @human2.pigs.create :name => 'small pig'

    deep_clone_human_2 = @human.deep_clone(:include => [:pigs])
    assert deep_clone_human_2.new_record?
    assert deep_clone_human_2.save
    assert_equal 1, deep_clone_human_2.pigs.count
  end

  def test_should_deep_clone_many_to_many_associations
    @human = Animal::Human.create :name => "Michael"
    @human2 = Animal::Human.create :name => "Jack"
    @chicken1 = Animal::Chicken.create :name => 'Chick1'
    @chicken2 = Animal::Chicken.create :name => 'Chick2'
    @human.chickens << [@chicken1, @chicken2]
    @human2.chickens << [@chicken1, @chicken2]

    deep_clone_human = @human.deep_clone(:include => :ownerships)
    assert deep_clone_human.new_record?
    assert deep_clone_human.save
    assert_equal 2, deep_clone_human.chickens.count
  end

  def test_should_deep_clone_with_block
    deep_clone = @jack.deep_clone(:include => :parrot) do |original, kopy|
      kopy.cloned_from_id = original.id
    end

    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal @jack.id, deep_clone.cloned_from_id
    assert_equal @jack.parrot.id, deep_clone.parrot.cloned_from_id
  end

  def test_should_deep_clone_habtm_associations
    @person1 = Person.create :name => "Bill"
    @person2 = Person.create :name => "Ted"
    @car1 = Car.create :name => 'Mustang'
    @car2 = Car.create :name => 'Camaro'
    @person1.cars << [@car1, @car2]
    @person2.cars << [@car1, @car2]

    deep_clone_person = @person1.deep_clone :include => :cars

    assert deep_clone_person.new_record?
    assert_equal [@person1, @person2, deep_clone_person], @car1.people
    assert_equal [@person1, @person2, deep_clone_person], @car2.people

    assert deep_clone_person.save

    # did NOT deep_clone the Car instances
    assert_equal 2, Car.all.count

    # did deep_clone the correct join table rows
    assert_equal @person1.cars, deep_clone_person.cars
    assert_equal 2, deep_clone_person.cars.count
  end

  def test_should_deep_clone_habtm_associations_with_missing_reverse_association
    @coin = Coin.create :value => 1
    @person = Person.create :name => "Bill"
    @coin.people << @person

    deep_clone = @coin.deep_clone :include => :people
    assert deep_clone.new_record?
    assert_equal [@person], @coin.people
    assert deep_clone.save
  end

  def test_should_deep_clone_joined_association
    subject1 = Subject.create(:name => 'subject 1')
    subject2 = Subject.create(:name => 'subject 2')
    student = Student.create(:name => 'Parent', :subjects => [subject1, subject2])

    deep_clone = student.deep_clone :include => { :student_assignments => :subject }
    deep_clone.save # Subjects will have been set after save
    assert_equal 2, deep_clone.subjects.size
    [subject1, subject2].each{|subject| assert !deep_clone.subjects.include?(subject) }
  end

  def test_parent_validations_run_on_save_after_clone
    child = ChildWithValidation.create :name => 'Jimmy'
    parent = ParentWithValidation.new :children => [child]
    parent.save :validate => false

    deep_clone_parent = parent.deep_clone :include => :children

    assert !deep_clone_parent.save
    assert deep_clone_parent.new_record?
    assert !deep_clone_parent.valid?
    assert deep_clone_parent.children.first.valid?
    assert_equal deep_clone_parent.errors.messages, :name => ["can't be blank"]
  end

  def test_parent_validations_dont_run_on_save_after_clone
    child = ChildWithValidation.create :name => 'Jimmy'
    parent = ParentWithValidation.new :children => [child]
    parent.save :validate => false

    deep_clone_parent = parent.deep_clone :include => :children, :validate => false

    assert deep_clone_parent.save
    assert !deep_clone_parent.new_record?
    assert !deep_clone_parent.valid?
    assert deep_clone_parent.children.first.valid?
    assert_equal deep_clone_parent.errors.messages, :name => ["can't be blank"]
  end

  def test_child_validations_run_on_save_after_clone
    child = ChildWithValidation.new
    child.save :validate => false
    parent = ParentWithValidation.create :name => 'John', :children => [child]

    deep_clone_parent = parent.deep_clone :include => :children

    assert !deep_clone_parent.save
    assert deep_clone_parent.new_record?
    assert !deep_clone_parent.valid?
    assert !deep_clone_parent.children.first.valid?
    assert_equal deep_clone_parent.errors.messages, :children => ["is invalid"]
  end

  def test_child_validations_run_on_save_after_clone_without_validation
    child = ChildWithValidation.new
    child.save :validate => false
    parent = ParentWithValidation.create :name => 'John', :children => [child]

    deep_clone_parent = parent.deep_clone :include => :children, :validate => false

    assert deep_clone_parent.save
    assert !deep_clone_parent.new_record?
    assert !deep_clone_parent.valid?
    assert !deep_clone_parent.children.first.valid?
    assert_equal deep_clone_parent.errors.messages, :children => ["is invalid"]
  end

  def test_self_join_has_many
    parent_part = Part.create(:name => 'Parent')
    child1 = Part.create(:name => 'Child 1', :parent_part_id => parent_part.id)
    child2 = Part.create(:name => 'Child 2', :parent_part_id => parent_part.id)

    deep_clone_part = parent_part.deep_clone :include => :child_parts
    assert deep_clone_part.save
    assert_equal 2, deep_clone_part.child_parts.size
  end

  def test_should_include_has_many_through_associations
    subject1 = Subject.create(:name => 'subject 1')
    subject2 = Subject.create(:name => 'subject 2')
    student = Student.create(:name => 'Parent', :subjects => [subject1, subject2])

    deep_clone = student.deep_clone :include => :subjects
    assert_equal 2, deep_clone.subjects.size
    assert_equal [[student, deep_clone],[student, deep_clone]], deep_clone.subjects.map{|subject| subject.students }
  end

  def test_should_deep_clone_unsaved_objects
    jack = Pirate.new(:name => 'Jack Sparrow', :nick_name => 'Captain Jack', :age => 30)
    jack.mateys.build(:name => 'John')

    deep_clone = jack.deep_clone(:include => :mateys)
    assert deep_clone.new_record?
    assert_equal 1, deep_clone.mateys.size
    assert_equal 'John', deep_clone.mateys.first.name
  end

  def test_should_reject_copies_if_conditionals_are_passed
    subject1 = Subject.create(:name => 'subject 1')
    subject2 = Subject.create(:name => 'subject 2')
    student = Student.create(:name => 'Parent', :subjects => [subject1, subject2])

    deep_clone = student.deep_clone :include => { :subjects => { :if => lambda{|subject| subject.name == 'subject 2' } } }
    assert_equal 1, deep_clone.subjects.size
    assert_equal 'subject 2', deep_clone.subjects.first.name

    deep_clone = @jack.deep_clone(:include => {
      :treasures => { :gold_pieces => { :unless => lambda{|piece| piece.is_a?(Parrot) } } },
      :mateys => { :if => lambda{|matey| matey.is_a?(GoldPiece) } }
    })

    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.treasures.size
    assert_equal 1, deep_clone.gold_pieces.size
    assert_equal 0, deep_clone.mateys.size
  end

  def test_should_properly_read_conditions_in_arrays
    subject1 = Subject.create(:name => 'subject 1')
    subject2 = Subject.create(:name => 'subject 2')
    student = Student.create(:name => 'Parent', :subjects => [subject1, subject2])

    deep_clone = student.deep_clone(:include => [:subjects => [:if => lambda{|subject| false }] ])
    assert deep_clone.subjects.none?

    deep_clone = student.deep_clone(:include => [:subjects => [:if => lambda{|subject| true }] ])
    assert_equal 2, deep_clone.subjects.size
  end

  def test_should_reject_copies_if_conditionals_are_passed_with_associations
    deep_clone = @ship.deep_clone(:include => [:pirates => [:treasures, :mateys, { :unless => lambda {|pirate| pirate.name == 'Jack Sparrow'} }]])

    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 0, deep_clone.pirates.size

    deep_clone = @ship.deep_clone(:include => [:pirates => [:treasures, :mateys, { :if => lambda {|pirate| pirate.name == 'Jack Sparrow'} }]])
    assert deep_clone.new_record?
    assert deep_clone.save
    assert_equal 1, deep_clone.pirates.size
  end

  def test_should_find_in_dict_for_habtm
    apt = Apartment.create(:number => "101")
    contractor = Contractor.create(:name => "contractor", :apartments => [apt])

    apt.contractors = [contractor]
    apt.save!

    building = Building.create(:name => "Tall Building", :contractors => [contractor], :apartments => [apt])

    deep_clone = building.deep_clone(:include => [
      :apartments,
      {
        :contractors => [
          :apartments
        ]
      }
    ],
    :use_dictionary => true)

    deep_clone.save!

    assert_equal deep_clone.contractors.first.apartments.first.id, deep_clone.apartments.first.id
    assert_equal deep_clone.apartments.first.contractors.first.id, deep_clone.contractors.first.id
  end

  def test_should_not_make_attributes_dirty_for_exceptions
    deep_clone = @jack.deep_clone(:except => :name)
    assert_nil deep_clone.name
    refute deep_clone.name_changed?
  end
end
