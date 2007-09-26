$:.unshift(File.dirname(__FILE__) + "/lib")
require 'rubygems'
require 'hoe'
require 'passive_record'

Hoe.new('PassiveRecord', PassiveRecord::VERSION) do |p|
  p.rubyforge_name  = 'paintitred'
  p.author          = 'Jason L Perry'
  p.email           = 'jasper@ambethia.com'
  p.summary         = 'Pacifying overactive records'
  p.description     = 'Pacifying overactive records'
  p.url             = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes         = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

desc "Run the test suite."
task :testo do
  Dir['test/test_*'].each do |file|
    system "ruby #{file}"
  end
end
