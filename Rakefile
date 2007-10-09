require 'rubygems'
require 'rake'

ENV['RUBY_FLAGS'] = "-I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}"

begin
  require 'echoe'

  Echoe.new("passiverecord") do |p|
    p.rubyforge_name  = 'paintitred'
    p.author          = 'Jason L Perry'
    p.email           = 'jasper@ambethia.com'
    p.summary         = 'Pacifying overactive records'
    p.url             = "http://code.itred.org/projects/passive-record"
    p.dependencies    = ["activerecord >= 1.15.3"]
  end
  
rescue LoadError => boom
  desc "Run the test suite."
  task :test do
     system "ruby -Ilib:ext:bin:test -e 'require \"test/test_associations.rb\"; require \"test/test_base.rb\"'"
  end

  task(:default) do
    puts "You are missing a dependency required for meta-operations on this gem."
    puts "#{boom.to_s.capitalize}."
  
    Rake::Task["test"].invoke 
  end    
end