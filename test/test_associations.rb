require 'test/unit'
require 'passive_record'

class Room < PassiveRecord::Base
  has_many :furniture, :order => :name
  has_one  :light_fixture, :class_name => "Furniture"
  
  schema :name => String
  
  create :name => "Family Room"
  create :name => "Kitchen"
  create :name => "Bedroom"
  create :name => "Restroom"
  create :name => "Office"
end

ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")
ActiveRecord::Base.connection.create_table "furniture", :force => true do |t|
  t.column :name,    :string
  t.column :room_id, :integer
end 

Inflector.inflections { |inflect| inflect.uncountable %w( furniture )}

class Furniture < ActiveRecord::Base
  # belongs_to :room
end

class PassiveRecordTest < Test::Unit::TestCase

  # some "fixtures"
  def setup
    Furniture.create :name => "Couch",    :room_id => Room.find_by_name("Family Room").id
    Furniture.create :name => "Ottoman",  :room_id => Room.find_by_name("Family Room").id
    Furniture.create :name => "Ott-lite", :room_id => Room.find_by_name("Office").id
  end
  
  def test_should_have_many
    furniture = [
      Furniture.find_by_name("Couch"),
      Furniture.find_by_name("Ottoman")
    ]
    room = Room.find_by_name("Family Room")
    assert_equal furniture, room.furniture
  end

  def test_should_have_one
    lamp = Furniture.find_by_name("Ott-lite")
    room = Room.find_by_name("Office")
    assert_equal lamp, room.light_fixture
  end
        
  def teardown
    Furniture.delete_all
  end
   
end