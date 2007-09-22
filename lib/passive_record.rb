module PassiveRecord VERSION = '0.0.1'; end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'passive_record/base'
require 'passive_record/schema'

PassiveRecord::Base.class_eval do
  include PassiveRecord::Schema
end