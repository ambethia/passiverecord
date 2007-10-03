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

class Room < PassiveRecord::Base
  has_many :furniture,      :order      => :name
  has_one  :light_fixture,  :class_name => "Furniture"
  
  has_many :ins,   :class_name => "Door", :foreign_key => "outside_id"
  has_many :outs,  :class_name => "Door", :foreign_key => "inside_id"
  
  has_many :exits,      :through => :outs
  has_many :entrances,  :through => :ins
  
  schema :name => String
  
  create 1, :name => "Family Room"
  create 2, :name => "Kitchen"
  create 3, :name => "Bedroom"
  create 4, :name => "Restroom"
  create 5, :name => "Office"
end