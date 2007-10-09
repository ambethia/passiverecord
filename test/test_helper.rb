require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_record/fixtures'
require 'active_support'
require 'active_support/breakpoint'

require File.dirname(__FILE__) + '/../lib/passive_record'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

require 'schema'
require 'continents'
require 'fosses'

class Test::Unit::TestCase #:nodoc:

  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end