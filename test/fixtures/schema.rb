ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")

ActiveRecord::Base.connection.create_table "sambocranks", :force => true do |t|
  t.column :name,    :string
  t.column :foss_id, :integer
end 

ActiveRecord::Base.connection.create_table "rhizocables", :force => true do |t|
  t.column :name,    :string
  t.column :foss_id, :integer
  t.column :sambocrank_id, :integer
end 

ActiveRecord::Base.connection.create_table "candraspouses", :force => true do |t|
  t.column :name,    :string
  t.column :foss_id, :integer
end 

class Sambocrank < ActiveRecord::Base
  belongs_to :foss
  has_many :rhizocables
end

class Rhizocable < ActiveRecord::Base
  belongs_to :foss
  belongs_to :sambocrank
end

class Candraspouse < ActiveRecord::Base
  belongs_to :foss
end
