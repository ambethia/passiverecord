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

    class << self

      def define(*args)
        attributes = extract_options!(args)
        key = args.first || @@instances.size+1
        instance = self.new(attributes)
        instance.key = key
        @@instances[key] = instance
        return key
      end

      def has_many(association_id, options = {})
      end

      def find(*args)
        options = extract_options!(args)

        case args.first
          # when :first then find_initial(options)
          when :all   then find_every(options)
          else             find_from_keys(args, options)
        end

      end

      def count(options = {})
        find_every(options).size
      end

      def delete_all
        @@instances = {}
      end

    protected

      # def find_initial(options)
      # end

      def find_every(options)
        @@instances
      end

      def find_from_keys(keys, options)
        expects_array = keys.first.kind_of?(Array)
        return keys.first if expects_array && keys.first.empty?
        keys = keys.flatten.compact.uniq

        case keys.size
          when 0
            raise RecordNotFound, "Couldn't find #{name} without a key"
          when 1
            result = find_one(keys.first, options)
            expects_array ? [ result ] : result
          else
            find_some(keys, options)
        end
      end

      def find_one(key, options)
        @@instances[key]
      end

      def find_some(keys, options)
        @@instances.values_at(*keys).compact
      end

      def extract_options!(args) #:nodoc:
        args.last.is_a?(Hash) ? args.pop : {}
      end

    end
  end
end