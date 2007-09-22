module PassiveRecord
  module Schema

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def schema(definition = {})
        @@schema = definition
        definition.keys.each do |attribute_name|
          define_method("#{attribute_name}") do
            self[attribute_name]
          end
          define_method("#{attribute_name}=") do |new_value|
            self[attribute_name] = new_value
          end
        end
      end
      
    end
  end
end
