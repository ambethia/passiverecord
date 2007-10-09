require File.dirname(__FILE__) + '/test_helper.rb'

class PassiveRecord::AssociationsTest < Test::Unit::TestCase
  
  def setup
    create_fixtures :candraspouses, :sambocranks, :rhizocables
  end
  
  def test_should_have_many
    sambocranks = [
      Sambocrank.find_by_name("Dakferous"),
      Sambocrank.find_by_name("Sambaular")
    ]
    foss = Foss.find_by_name("Hypogenoaular")
    assert_equal sambocranks, foss.sambocranks
  end

  def test_should_have_many_through
    foss = Foss.find_by_name("Zaxment")
    
    rhizocables = [
      Rhizocable.find_by_name("Ovumgyps"),
      Rhizocable.find_by_name("Alfmetric")
    ]
    
    assert_equal rhizocables, foss.rhizocables
  end

  def test_should_have_one
    candraspouse = Candraspouse.find_by_name("Maiamorphic")
    foss = Foss.find_by_name("Zaxment")
    
    assert_equal candraspouse, foss.candraspouse
  end
  
  def test_should_belong_to
    candraspouse = Candraspouse.find_by_name("Eyenium")
    foss = Foss.find_by_name("Hypogenoaular")
    
    assert_equal foss, candraspouse.foss
  end  
end