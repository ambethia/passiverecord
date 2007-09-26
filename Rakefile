$:.unshift(File.dirname(__FILE__) + "/lib")
require 'rubygems'
require 'hoe'

require 'passive_record/version'

Hoe.new('PassiveRecord', PassiveRecord::VERSION::STRING) do |p|
  p.rubyforge_name  = 'paintitred'
  p.author          = 'Jason L Perry'
  p.email           = 'jasper@ambethia.com'
  p.summary         = 'Pacifying overactive records'
  p.description     = 'Pacifying overactive records'
  p.url             = "http://code.itred.org/projects/passive-record"
  p.changes         = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps      = ['activerecord', '>= 1.15.3']
  p.remote_rdoc_dir = "paintitred/passive_record"
end
