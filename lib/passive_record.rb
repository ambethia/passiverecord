$:.unshift(File.dirname(__FILE__))

begin
  require 'active_record'
rescue LoadError => e
  require 'rubygems'
  require 'active_record'
end

require 'passive_record/base'
require 'passive_record/schema'
require 'passive_record/associations'

PassiveRecord::Base.class_eval do
  include PassiveRecord::Schema
  include PassiveRecord::Associations
end
