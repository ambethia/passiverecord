# Currently this is a big hack job of code from active record
# TODO: Trim this down, and test it thoroughly
module PassiveRecord
  module Associations
    
    def self.included(base)
      base.extend(ClassMethods)

      ActiveRecord::Callbacks::CALLBACKS.each do |method|
        base.class_eval <<-"end_eval"
          def self.#{method}(*callbacks, &block)
            callbacks << block if block_given?
            write_inheritable_array(#{method.to_sym.inspect}, callbacks)
          end
        end_eval
      end
    end

    def quoted_id #:nodoc:
      ActiveRecord::Base.quote_value(self.key)
    end
    
    def attribute_present?(attribute)
      value = self.respond_to?(attribute) ? self.send(attribute) : nil
      !value.blank? or value == 0
    end
    
    def read_attribute(attribute)
      self.send(attribute)
    end
    
    def new_record?
      false
    end
    
    module ClassMethods

      def has_many(association_id, options = {}, &extension)
        reflection = create_has_many_reflection(association_id, options, &extension)

        ActiveRecord::Base.send(:configure_dependency_for_has_many, reflection)

        if options[:through]
          collection_reader_method(reflection, ActiveRecord::Associations::HasManyThroughAssociation)
        else
          add_multiple_associated_save_callbacks(reflection.name)
          add_association_callbacks(reflection.name, reflection.options)
          collection_accessor_methods(reflection, ActiveRecord::Associations::HasManyAssociation)
        end
      end
      
      def has_one(association_id, options = {})
        reflection = create_has_one_reflection(association_id, options)

        module_eval do
          after_save <<-EOF
            association = instance_variable_get("@#{reflection.name}")
            if !association.nil? && (new_record? || association.new_record? || association["#{reflection.primary_key_name}"] != id)
              association["#{reflection.primary_key_name}"] = id
              association.save(true)
            end
          EOF
        end
      
        association_accessor_methods(reflection, ActiveRecord::Associations::HasOneAssociation)
        association_constructor_method(:build,  reflection, ActiveRecord::Associations::HasOneAssociation)
        association_constructor_method(:create, reflection, ActiveRecord::Associations::HasOneAssociation)
        
        ActiveRecord::Base.send(:configure_dependency_for_has_one, reflection)
      end
      
      def create_has_many_reflection(association_id, options, &extension)
        options.assert_valid_keys(
          :class_name, :table_name, :foreign_key,
          :exclusively_dependent, :dependent,
          :select, :conditions, :include, :order, :group, :limit, :offset,
          :as, :through, :source, :source_type,
          :uniq,
          :finder_sql, :counter_sql, 
          :before_add, :after_add, :before_remove, :after_remove, 
          :extend
        )

        options[:extend] = create_extension_module(association_id, extension) if block_given?

        create_reflection(:has_many, association_id, options, self)
      end

      def create_has_one_reflection(association_id, options)
        options.assert_valid_keys(
          :class_name, :foreign_key, :remote, :conditions, :order, :include, :dependent, :counter_cache, :extend, :as
        )

        create_reflection(:has_one, association_id, options, self)
      end

      def create_reflection(macro, name, options, active_record)
        case macro
          when :has_many, :belongs_to, :has_one, :has_and_belongs_to_many
            reflection = ActiveRecord::Reflection::AssociationReflection.new(macro, name, options, active_record)
          when :composed_of
            reflection = AggregateReflection.new(macro, name, options, active_record)
        end
        write_inheritable_hash :reflections, name => reflection
        reflection
      end
      
      def reflections
        read_inheritable_attribute(:reflections) || write_inheritable_attribute(:reflections, {})
      end
            
      def add_multiple_associated_save_callbacks(association_name)
        method_name = "validate_associated_records_for_#{association_name}".to_sym
        define_method(method_name) do
          association = instance_variable_get("@#{association_name}")
          if association.respond_to?(:loaded?)
            if new_record?
              association
            else
              association.select { |record| record.new_record? }
            end.each do |record|
              errors.add "#{association_name}" unless record.valid?
            end
          end
        end

        validate method_name
        before_save("@new_record_before_save = new_record?; true")

        after_callback = <<-end_eval
          association = instance_variable_get("@#{association_name}")
          
          if association.respond_to?(:loaded?)
            if @new_record_before_save
              records_to_save = association
            else
              records_to_save = association.select { |record| record.new_record? }
            end
            records_to_save.each { |record| association.send(:insert_record, record) }
            association.send(:construct_sql)   # reconstruct the SQL queries now that we know the owner's id
          end
        end_eval
              
        # Doesn't use after_save as that would save associations added in after_create/after_update twice
        after_create(after_callback)
        after_update(after_callback)
      end

      def add_association_callbacks(association_name, options)
        callbacks = %w(before_add after_add before_remove after_remove)
        callbacks.each do |callback_name|
          full_callback_name = "#{callback_name}_for_#{association_name}"
          defined_callbacks = options[callback_name.to_sym]
          if options.has_key?(callback_name.to_sym)
            class_inheritable_reader full_callback_name.to_sym
            write_inheritable_array(full_callback_name.to_sym, [defined_callbacks].flatten)
          end
        end
      end
      
      def collection_accessor_methods(reflection, association_proxy_class)
        collection_reader_method(reflection, association_proxy_class)

        define_method("#{reflection.name}=") do |new_value|
          # Loads proxy class instance (defined in collection_reader_method) if not already loaded
          association = send(reflection.name) 
          association.replace(new_value)
          association
        end

        define_method("#{reflection.name.to_s.singularize}_ids") do
          send(reflection.name).map(&:id)
        end

        define_method("#{reflection.name.to_s.singularize}_ids=") do |new_value|
          ids = (new_value || []).reject { |nid| nid.blank? }
          send("#{reflection.name}=", reflection.class_name.constantize.find(ids))
        end
      end
      
      def collection_reader_method(reflection, association_proxy_class)
        define_method(reflection.name) do |*params|
          
          force_reload = params.first unless params.empty?
          association = instance_variable_get("@#{reflection.name}")
          unless association.respond_to?(:loaded?)
            association = association_proxy_class.new(self, reflection)
            instance_variable_set("@#{reflection.name}", association)
          end
          association.reload if force_reload
          
          association
        end
      end
      
      def association_accessor_methods(reflection, association_proxy_class)
        define_method(reflection.name) do |*params|
          force_reload = params.first unless params.empty?
          association = instance_variable_get("@#{reflection.name}")

          if association.nil? || force_reload
            association = association_proxy_class.new(self, reflection)
            retval = association.reload
            if retval.nil? and association_proxy_class == BelongsToAssociation
              instance_variable_set("@#{reflection.name}", nil)
              return nil
            end
            instance_variable_set("@#{reflection.name}", association)
          end

          association.target.nil? ? nil : association
        end

        define_method("#{reflection.name}=") do |new_value|
          association = instance_variable_get("@#{reflection.name}")
          if association.nil?
            association = association_proxy_class.new(self, reflection)
          end

          association.replace(new_value)

          unless new_value.nil?
            instance_variable_set("@#{reflection.name}", association)
          else
            instance_variable_set("@#{reflection.name}", nil)
            return nil
          end

          association
        end

        define_method("set_#{reflection.name}_target") do |target|
          return if target.nil? and association_proxy_class == BelongsToAssociation
          association = association_proxy_class.new(self, reflection)
          association.target = target
          instance_variable_set("@#{reflection.name}", association)
        end
      end

      def association_constructor_method(constructor, reflection, association_proxy_class)
        define_method("#{constructor}_#{reflection.name}") do |*params|
          attributees      = params.first unless params.empty?
          replace_existing = params[1].nil? ? true : params[1]
          association      = instance_variable_get("@#{reflection.name}")

          if association.nil?
            association = association_proxy_class.new(self, reflection)
            instance_variable_set("@#{reflection.name}", association)
          end

          if association_proxy_class == HasOneAssociation
            association.send(constructor, attributees, replace_existing)
          else
            association.send(constructor, attributees)
          end
        end
      end

      def validate(*methods, &block)
        methods << block if block_given?
        write_inheritable_set(:validate, methods)
      end

      def write_inheritable_set(key, methods)
        existing_methods = read_inheritable_attribute(key) || []
        write_inheritable_attribute(key, methods | existing_methods)
      end

      def compute_type(*args)
        ActiveRecord::Base.send(:compute_type, *args)
      end
      
      def reflect_on_association(association)
        reflections[association].is_a?(ActiveRecord::Reflection::AssociationReflection) ? reflections[association] : nil
      end
      
      def table_name
        "table_name_foo"
      end
      
      def primary_key
        "primary_key_bar"
      end
      
    end
  end
end
