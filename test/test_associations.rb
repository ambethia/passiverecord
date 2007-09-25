require 'test/unit'
require 'passive_record'

class Room < PassiveRecord::Base
  has_many :furniture, :order => :name
  has_one  :light_fixture, :class_name => "Furniture"
  
  has_many :ins,   :class_name => "Door", :foreign_key => "outside_id"
  has_many :outs,  :class_name => "Door", :foreign_key => "inside_id"
  
  has_many :exits, :through => :outs
  has_many :entrances, :through => :ins
  
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

ActiveRecord::Base.connection.create_table "doors", :force => true do |t|
  t.column :inside_id,  :integer
  t.column :outside_id, :integer
end 

Inflector.inflections { |inflect| inflect.uncountable %w( furniture )}

class Furniture < ActiveRecord::Base
  belongs_to :room
end

class Door < ActiveRecord::Base
  belongs_to :inside,   :class_name => "Room", :foreign_key => "inside_id"
  belongs_to :outside,  :class_name => "Room", :foreign_key => "outside_id"
end

class PassiveRecordTest < Test::Unit::TestCase

  # some "fixtures"
  def setup
    Furniture.create :name => "Couch",    :room_id => Room.find_by_name("Family Room").id
    Furniture.create :name => "Ottoman",  :room_id => Room.find_by_name("Family Room").id
    Furniture.create :name => "Ott-lite", :room_id => Room.find_by_name("Office").id
    
    Door.create :inside_id  => Room.find_by_name("Office").id,
                :outside_id => Room.find_by_name("Family Room").id
                
    Door.create :inside_id  => Room.find_by_name("Restroom").id,
                :outside_id => Room.find_by_name("Family Room").id
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
    
    assert_equal room, room.exits
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
  
  def teardown
    Furniture.delete_all
  end
   
end