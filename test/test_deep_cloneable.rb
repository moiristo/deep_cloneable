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
    assert dup.save
    assert_equal @jack.name, @jack.send(@@clone_method).name # Old behaviour
    assert_nil dup.name
    assert_equal @jack.nick_name, dup.nick_name
  end

  def test_multiple_dup_exception
    dup = @jack.send(@@clone_method, :except => [:name, :nick_name])
    assert dup.save
    assert_nil dup.name
    assert_equal 'no nickname', dup.nick_name
    assert_equal @jack.age, dup.age
  end

  def test_single_include_association
    dup = @jack.send(@@clone_method, :include => :mateys)
    assert dup.save
    assert_equal 1, dup.mateys.size
  end

  def test_single_include_belongs_to_polymorphic_association
    dup = @jack.send(@@clone_method, :include => :ship)
    assert dup.save
    assert_not_nil dup.ship
    assert_not_equal @jack.ship, dup.ship
  end

  def test_single_include_has_many_polymorphic_association
    dup = @ship.send(@@clone_method, :include => :pirates)
    assert dup.save
    assert dup.pirates.any?
  end

  def test_multiple_include_association
    dup = @jack.send(@@clone_method, :include => [:mateys, :treasures])
    assert dup.save
    assert_equal 1, dup.mateys.size
    assert_equal 1, dup.treasures.size
  end

  def test_deep_include_association
    dup = @jack.send(@@clone_method, :include => {:treasures => :gold_pieces})
    assert dup.save
    assert_equal 1, dup.treasures.size
    assert_equal 1, dup.gold_pieces.size
  end

  def test_include_association_assignments
    dup = @jack.send(@@clone_method, :include => :treasures)

    dup.treasures.each do |treasure|
      assert_equal dup, treasure.pirate
    end
  end

  def test_multiple_and_deep_include_association
    dup = @jack.send(@@clone_method, :include => {:treasures => :gold_pieces, :mateys => {}})
    assert dup.save
    assert_equal 1, dup.treasures.size
    assert_equal 1, dup.gold_pieces.size
    assert_equal 1, dup.mateys.size
  end

  def test_multiple_and_deep_include_association_with_array
    dup = @jack.send(@@clone_method, :include => [{:treasures => :gold_pieces}, :mateys])
    assert dup.save
    assert_equal 1, dup.treasures.size
    assert_equal 1, dup.gold_pieces.size
    assert_equal 1, dup.mateys.size
  end

  def test_with_belongs_to_relation
    dup = @jack.send(@@clone_method, :include => :parrot)
    assert dup.save
    assert_not_equal dup.parrot, @jack.parrot
  end

  def test_should_pass_nested_exceptions
    dup = @jack.send(@@clone_method, :include => :parrot, :except => [:name, { :parrot => [:name] }])
    assert dup.save
    assert_not_equal dup.parrot, @jack.parrot
    assert_not_nil @jack.parrot.name
    assert_nil dup.parrot.name
  end

  def test_should_not_double_dup_when_using_dictionary
    current_matey_count = Matey.count
    dup = @jack.send(@@clone_method, :include => [:mateys, { :treasures => :matey }], :use_dictionary => true)
    dup.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_not_double_dup_when_using_manual_dictionary
    current_matey_count = Matey.count

    dict = { :mateys => {} }
    @jack.mateys.each{|m| dict[:mateys][m] = m.send(@@clone_method) }

    dup = @jack.send(@@clone_method, :include => [:mateys, { :treasures => :matey }], :dictionary => dict)
    dup.save!

    assert_equal current_matey_count + 1, Matey.count
  end

  def test_should_support_ar_class_under_module
    @human = Animal::Human.create :name => "Michael"
    @pig = Animal::Pig.create :human => @human, :name => 'big pig'

    dup_human = @human.send(@@clone_method, :include => [:pigs])
    assert dup_human.save
    assert_equal 1, dup_human.pigs.count
    
    @human2 = Animal::Human.create :name => "John"
    @pig2 = @human2.pigs.create :name => 'small pig'
    
    dup_human_2 = @human.send(@@clone_method, :include => [:pigs])
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
    assert dup_human.save
    assert_equal 2, dup_human.chickens.count    
  end 
  
  def test_should_dup_with_block
    dup = @jack.send(@@clone_method, :include => :parrot) do |original, kopy|
      kopy.cloned_from_id = original.id
    end

    assert dup.save
    assert_equal @jack.id, dup.cloned_from_id
    assert_equal @jack.parrot.id, dup.parrot.cloned_from_id
  end
end
