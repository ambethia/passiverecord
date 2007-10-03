module PassiveRecord
  class PassiveRecordError < StandardError; end
  class RecordNotFound < PassiveRecordError; end

  class Base
    @@instances = {}

    attr_accessor :attributes, :key

    alias :id :key

    def initialize(attributes = {})
      @attributes = attributes
      yield self if block_given?
    end

    def [](attribute_name)
      self.attributes[attribute_name]
    end

    def []=(attribute_name, value)
      self.attributes[attribute_name] = value
    end

    def ==(comparison_object)
      comparison_object.equal?(self) ||
        (comparison_object.instance_of?(self.class) && 
          comparison_object.id == id && 
          !comparison_object.new_record?)
    end
    

    class << self

      def create(*args)
        attributes = extract_options!(args)
        key = args.first || find_every.size+1
        instance = self.new(attributes)
        instance.key = key
        @@instances[base_key(key)] = instance
        return key
      end

      private :create

      def find(*args)
        options = extract_options!(args)
        args.first == :all ? find_every : find_from_keys(args)
      end

      def count
        find_every.size
      end
      
      def base_class
        class_of_passive_record_descendant(self)
      end

    protected

      # def find_initial(options)
      # end

      def find_every
        @@instances.select { |key, value| value.is_a?(self) }.map {|its| its.last}
      end

      def find_from_keys(keys, options = {})
        
        expects_array = keys.first.kind_of?(Array)
        return keys.first if expects_array && keys.first.empty?
        keys = keys.flatten.compact.uniq

        case keys.size
          when 0
            raise RecordNotFound, "Couldn't find #{name} without a key"
          when 1
            result = find_one(keys.first)
            expects_array ? [ result ] : result
          else
            find_some(keys)
        end
      end

      def find_one(_key)
        values = @@instances.select { |key, value| base_key(_key) == key && value.is_a?(self) }.map {|its| its.last}
        unless values.empty?
          return values.first
        else
          raise RecordNotFound, "Couldn't find #{name} with the given key."
        end
      end

      def find_some(keys)
        base_keys = keys.map { |key| base_key(key)  }
        values = @@instances.select { |key, value| (base_keys).include?(key) && value.is_a?(self) }.map {|its| its.last }
      end

      def extract_options!(args) #:nodoc:
        args.last.is_a?(Hash) ? args.pop : {}
      end
      
      # TODO: clean this mess up
      def method_missing(method_id, *arguments)
        if match = /^find_(all_by|by)_([_a-zA-Z]\w*)$/.match(method_id.to_s)
          expects_array   = match.captures.first == 'all_by'
          attribute_names = match.captures.last.split('_and_')
          # super unless all_attributes_exists?(attribute_names)
          attributes = {}
          attribute_names.each_with_index { |name, idx| attributes[name] = arguments[idx] }
          expressions = ["value.is_a?(self)"]
          attributes.each_pair { |key, value| expressions << attribute_expression("value.#{key}", value)  }          
          results = @@instances.select { |key, value| eval expressions.join(" && ")  }.map {|its| its.last}
          return expects_array ? results : results.pop
        else
          super
        end
      end
            
      def attribute_expression(name, argument)
        case argument
        when Regexp then "#{name} =~ /#{argument}/"
        when Range  then "(#{argument}).include?(#{name})"
        when String then "#{name} == \"#{argument}\""
        else             "#{name} == #{argument}"
        end
      end
      
      # Returns the class descending directly from PassiveRecord in the inheritance hierarchy.
      def base_class(klass = self)
        if klass.superclass == Base
          klass
        elsif klass.superclass.nil?
          raise PassiveRecordError, "#{name} doesn't belong in a hierarchy descending from PassiveRecord"
        else
          base_class(klass.superclass)
        end
      end
            
      # Returns the real hash key used to store instances.
      # Keys are name spaced with their class name, ie "Continent:1"
      def base_key(key)
        "#{base_class.name}:#{key}"
      end
      
      # Returns the key portion of a +base_key+
      def key_base(base_key)
        base_key.split(":").last
      end
      
    end
  end
end
