class Continent < PassiveRecord::Base
  schema :name => String, :size => Integer, :population => Integer  
  
  create :name => "Africa",        :size => 30370000, :population => 890000000
  create :name => "Antarctica",    :size => 13720000, :population => 1000
  create :name => "Australia",     :size => 7600000,  :population => 20000000
  create :name => "Eurasia",       :size => 53990000, :population => 4510000000
  create :name => "North America", :size => 24490000, :population => 515000000
  create :name => "South America", :size => 17840000, :population => 371000000
end
