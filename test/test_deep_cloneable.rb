require File.dirname(__FILE__) + '/test_helper'

class TestDeepCloneable < Test::Unit::TestCase
  load_schema

  def setup
    @jack  = Pirate.create(:name => 'Jack Sparrow', :nick_name => 'Captain Jack', :age => 30)
    @polly = Parrot.create(:name => 'Polly', :pirate => @jack)
    @john = Matey.create(:name => 'John', :pirate => @jack)
    @treasure = Treasure.create(:found_at => 'Isla del Muerte', :pirate => @jack)
    @gold_piece = GoldPiece.create(:treasure => @treasure)
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
end