class Foss < PassiveRecord::Base
  has_one :candraspouse
    
  has_many :sambocranks
  has_many :rhizocables, :through => :sambocranks
  
  schema :name => String
  
  create 1, :name => "Hypogenoaular"
  create 2, :name => "Zaxment"
  create 3, :name => "Yelpscope"
  create 4, :name => "Dramisation"
  create 5, :name => "Codory"
end