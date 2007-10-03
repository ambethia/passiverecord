require File.dirname(__FILE__) + '/test_helper.rb'

class PassiveRecord::BaseTest < Test::Unit::TestCase
  
  def test_should_create_instance
    assert_equal 7, Continent.send(:create, :name => "Atlantis", :size => 0, :population => 0)
    PassiveRecord::Base.send(:class_variable_get, "@@instances").delete("Continent:7")
  end
  
  def test_should_create_instance_with_manual_key
    assert_equal "ATL", Continent.send(:create, "ATL", :name => "Atlantis", :size => 0, :population => 0)
    assert Continent.find("ATL")
    PassiveRecord::Base.send(:class_variable_get, "@@instances").delete("Continent:ATL")
  end
  
  def test_should_count_instances
    assert_equal 6, Continent.count
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
  
  def test_should_find_by_attribute
    assert_equal Continent.find(1), Continent.find_by_name("Africa")
    assert_equal Continent.find(5), Continent.find_by_population(515000000)
  end
  
  def test_should_find_all_by_attribute_as_regex
    assert_equal Continent.find(5,6), Continent.find_all_by_name(/America/)
  end

  def test_should_find_all_by_attribute_in_range
    assert_equal Continent.find(2,3), Continent.find_all_by_population(1000..20000000)
  end
  
  def test_should_find_by_many_attributes
    assert_equal Continent.find(6), Continent.find_by_name_and_size(/America/, 17840000)
  end

end