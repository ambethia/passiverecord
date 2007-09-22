require 'test/unit'
require 'passive_record'

class Room < PassiveRecord::Base
  has_many :furniture
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
end

class PassiveRecordTest < Test::Unit::TestCase
  
  def setup
    Furniture.create :name => "Couch",   :room_id => Room.find_by_name("Family Room").id
    Furniture.create :name => "Ottoman", :room_id => Room.find_by_name("Family Room").id
  end
  
  def test_should_have_many
    room = Room.find_by_name("Family Room")
    assert_equal 2, room.furniture.size
  end
        
  def teardown
    Furniture.delete_all
  end
   
end