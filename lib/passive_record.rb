module PassiveRecord VERSION = '0.0.1'; end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

unless defined?(ActiveRecord)
  begin
    $:.unshift(File.dirname(__FILE__) + "/../../activerecord/lib")  
    require 'active_record'  
  rescue LoadError
    require 'rubygems'
    require 'active_record'
  end
end

require 'passive_record/base'
require 'passive_record/schema'
require 'passive_record/delegation'

PassiveRecord::Base.class_eval do
  include PassiveRecord::Schema
  include PassiveRecord::Delegation
  delegate_class ActiveRecord::Base, :has_many
  
end