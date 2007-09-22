require 'test/unit'
require 'passive_record'

class Foo
  include PassiveRecord::Delegation
  
  delegate_instance Array, :size, :push, :pop, :<<, :[]
  delegate_class    Array, :bar
end

class Array
  def self.bar(msg)
    "#{msg}!!"
  end
end

class DelegationTest < Test::Unit::TestCase
  def test_methods_are_added_correctly
    foo = Foo.new
    foo.push "one"
    assert_equal 1, foo.size
    foo << "baz"
    assert_equal 2, foo.size
    assert_equal "baz", foo[1]
  end
  
  def test_class_methods_are_added_correctly
    puts Foo.__delegate_class__
    assert_equal "KAPOW!!", Foo.bar("KAPOW")
  end
end