PassiveRecord
    by Jason L Perry 
    http://paint.itred.org

== DESCRIPTION:
  
A replacement for ActiveRecord when you just need to model
a few unchanging objects, and don't necessarily need a full blown
ActiveRecord class and table in the database.

== FEATURES/PROBLEMS:
  
* None yet

== SYNOPSIS:

  # 6 Continent model
  class Continent < PassiveRecord::Base
    schema :name => String,          :size => Integer,  :population => Integer
  
    define :name => "Africa",        :size => 30370000, :population => 890000000 
    define :name => "Antarctica",    :size => 13720000, :population => 1000
    define :name => "Australia",     :size => 7600000,  :population => 20000000
    define :name => "Eurasia",       :size => 53990000, :population => 4510000000
    define :name => "North America", :size => 24490000, :population => 515000000
    define :name => "South America", :size => 17840000, :population => 371000000
  end

== REQUIREMENTS:

* None (ActiveRecord optional)

== INSTALL:

* require "passive_record"

== LICENSE:

(The MIT License)

Copyright (c) 2007 Jason L Perry (Paint.itRed)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
