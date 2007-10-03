require File.dirname(__FILE__) + '/test_helper.rb'

class PassiveRecord::AssociationsTest < Test::Unit::TestCase
  
  def setup
    create_fixtures :doors, :furniture
  end
  
  def test_should_have_many
    furniture = [
      Furniture.find_by_name("Couch"),
      Furniture.find_by_name("Ottoman")
    ]
    room = Room.find_by_name("Family Room")
    assert_equal furniture, room.furniture
  end

  def test_should_have_many_through
    rooms = [
      Room.find_by_name("Office"),
      Room.find_by_name("Restroom")
    ]
    
    room = Room.find_by_name("Family Room")
    
    # assert_equal room, room.exits
  end

  def test_should_have_one
    lamp = Furniture.find_by_name("Ott-lite")
    room = Room.find_by_name("Office")
    assert_equal lamp, room.light_fixture
  end
  
  def test_should_belong_to
    lamp = Furniture.find_by_name("Ott-lite")
    room = Room.find_by_name("Office")

    assert_equal room, lamp.room    
  end  
end