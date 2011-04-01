require File.dirname(__FILE__) + '/test_helper'

class TestDeepCloneable < Test::Unit::TestCase
  load_schema

  def setup
    @jack  = Pirate.create(:name => 'Jack Sparrow', :nick_name => 'Captain Jack', :age => 30)
    @polly = Parrot.create(:name => 'Polly', :pirate => @jack)
    @john = Matey.create(:name => 'John', :pirate => @jack)
    @treasure = Treasure.create(:found_at => 'Isla del Muerte', :pirate => @jack, :matey => @john)
    @gold_piece = GoldPiece.create(:treasure => @treasure)
    @ship = BattleShip.create(:name => 'Black Pearl', :pirates => [@jack])
  end

  def test_single_clone_exception
    clone = @jack.clone(:except => :name)
    assert clone.save
    assert_equal @jack.name, @jack.clone.name # Old behaviour
    assert_nil clone.name
    assert_equal @jack.nick_name, clone.nick_name
  end

  def test_multiple_clone_exception
    clone = @jack.clone(:except => [:name, :nick_name])
    assert clone.save
    assert_nil clone.name
    assert_equal 'no nickname', clone.nick_name
    assert_equal @jack.age, clone.age
  end

  def test_single_include_association
    clone = @jack.clone(:include => :mateys)
    assert clone.save
    assert_equal 1, clone.mateys.size
  end

  def test_single_include_belongs_to_polymorphic_association
    clone = @jack.clone(:include => :ship)
    assert clone.save
    assert_not_nil clone.ship
    assert_not_equal @jack.ship, clone.ship
  end

  def test_single_include_has_many_polymorphic_association
    clone = @ship.clone(:include => :pirates)
    assert clone.save
    assert clone.pirates.any?
  end

  def test_multiple_include_association
    clone = @jack.clone(:include => [:mateys, :treasures])
    assert clone.save
    assert_equal 1, clone.mateys.size
    assert_equal 1, clone.treasures.size
  end

  def test_deep_include_association
    clone = @jack.clone(:include => {:treasures => :gold_pieces})
    assert clone.save
    assert_equal 1, clone.treasures.size
    assert_equal 1, clone.gold_pieces.size
  end

  def test_include_association_assignments
    clone = @jack.clone(:include => :treasures)

    clone.treasures.each do |treasure|
      assert_equal clone, treasure.pirate
    end
  end

  def test_multiple_and_deep_include_association
    clone = @jack.clone(:include => {:treasures => :gold_pieces, :mateys => {}})
    assert clone.save
    assert_equal 1, clone.treasures.size
    assert_equal 1, clone.gold_pieces.size
    assert_equal 1, clone.mateys.size
  end

  def test_multiple_and_deep_include_association_with_array
    clone = @jack.clone(:include => [{:treasures => :gold_pieces}, :mateys])
    assert clone.save
    assert_equal 1, clone.treasures.size
    assert_equal 1, clone.gold_pieces.size
    assert_equal 1, clone.mateys.size
  end

  def test_with_belongs_to_relation
    clone = @jack.clone(:include => :parrot)
    assert clone.save
    assert_not_equal clone.parrot, @jack.parrot
  end

  def test_should_pass_nested_exceptions
    clone = @jack.clone(:include => :parrot, :except => [:name, { :parrot => [:name] }])
    assert clone.save
    assert_not_equal clone.parrot, @jack.parrot
    assert_not_nil @jack.parrot.name
    assert_nil clone.parrot.name
  end

  def test_should_not_double_clone_when_using_dictionary
    current_matey_count = Matey.count
    clone = @jack.clone(:include => [:mateys, { :treasures => :matey }], :use_dictionary => true)
    clone.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_not_double_clone_when_using_manual_dictionary
    current_matey_count = Matey.count

    dict = { :mateys => {} }
    @jack.mateys.each{|m| dict[:mateys][m] = m.clone }

    clone = @jack.clone(:include => [:mateys, { :treasures => :matey }], :dictionary => dict)
    clone.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_support_ar_class_under_module
    @human = Animal::Human.create :name => "Michael"
    @pig = Animal::Pig.create :human => @human, :name => 'big pig'

    clone_human = @human.clone :include => [:pigs]
    assert clone_human.save
    assert_equal 1, clone_human.pigs.count
    
    @human2 = Animal::Human.create :name => "John"
    @pig2 = @human2.pigs.create :name => 'small pig'
    
    clone_human_2 = @human.clone :include => [:pigs]
    assert clone_human_2.save
    assert_equal 1, clone_human_2.pigs.count
  end 
  
  def test_should_clone_many_to_many_associations
    @human = Animal::Human.create :name => "Michael" 
    @human2 = Animal::Human.create :name => "Jack"        
    @chicken1 = Animal::Chicken.create :name => 'Chick1'
    @chicken2 = Animal::Chicken.create :name => 'Chick2'    
    @human.chickens << [@chicken1, @chicken2]
    @human2.chickens << [@chicken1, @chicken2]    
    
    clone_human = @human.clone :include => :ownerships
    assert clone_human.save
    assert_equal 2, clone_human.chickens.count    
  end 
  
end
