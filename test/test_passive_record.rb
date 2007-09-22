require 'test/unit'
require 'passive_record'

class Continent < PassiveRecord::Base
  schema :name => String, :size => Integer, :population => Integer  
end

class PassiveRecordTest < Test::Unit::TestCase
  
  def setup
    # geographic 6 continent model
    Continent.define :name => "Africa",        :size => 30370000, :population => 890000000 
    Continent.define :name => "Antarctica",    :size => 13720000, :population => 1000
    Continent.define :name => "Australia",     :size => 7600000,  :population => 20000000
    Continent.define :name => "Eurasia",       :size => 53990000, :population => 4510000000
    Continent.define :name => "North America", :size => 24490000, :population => 515000000
    Continent.define :name => "South America", :size => 17840000, :population => 371000000
  end
    
  def test_should_define_instance
    assert_equal 7, Continent.define(:name => "Atlantis")
  end
  
  def test_should_count_instances
    assert_equal 6, Continent.count
  end

  def test_should_delete_all_instances
    assert_equal 6, Continent.count
    Continent.delete_all
    assert_equal 0, Continent.count
  end
    
  def test_should_find_one_by_key
    assert Continent.find(1).is_a?(Continent)
  end

  def test_should_find_one_by_key_as_array
    assert Continent.find([6]).is_a?(Array)
  end

  def test_should_find_some_by_key
    assert_equal 2, Continent.find(1,2).size
  end

  def test_should_find_some_by_key_as_array
    assert_equal 2, Continent.find([5,6]).size
    assert_equal 2, Continent.find([5,6,7]).size
  end
  
  def test_should_find_all
    assert_equal 6, Continent.find(:all).size
  end
    
  def test_should_get_attributes
    assert_equal "Africa", Continent.find(1).name
    assert_equal 1000,     Continent.find(2).population
  end

  def test_should_set_attributes
    assert Continent.find(1).name = "Motherland"
    assert_equal "Motherland", Continent.find(1).name
  end
  
  # def test_should_find_by_attribute
  #   assert_equal Continent.find(1), Continent.find_by_name("Africa")
  #   assert_equal Continent.find(5), Continent.find_by_population(515000000)
  # end
  
  def teardown
    Continent.delete_all
  end
   
end