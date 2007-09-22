# Delegation of instance methods by Jay Fields
#  http://blog.jayfields.com/2006/03/ruby-delegation-module.html
# Extended to include delegation of class level methods.
module PassiveRecord
  module Delegation
    def delegate_instance(klass, *methods)
      define_method("__delegate_instance__") { @__delegate_instance__ ||= klass.new }
      methods.each do |method|
        define_method(method.to_s) { |*args| __delegate_instance__.send method.to_sym, *args }
      end
    end

    def delegate_class(klass, *methods)
      self.class.send :define_method, "__delegate_class__", Proc.new{ @@__delegate_class__ ||= klass }
      methods.each do |method|
        self.class.send :define_method, method.to_s, Proc.new { |*args| __delegate_class__.send method.to_sym, *args }
      end
    end

    def self.append_features(mod)
      mod.extend(self)
    end
  end
end