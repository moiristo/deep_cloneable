require "active_record"

class ActiveRecord::Base
  module DeepCloneable

    # Deep dups an ActiveRecord model. See README.rdoc
    def deep_clone *args, &block
      options = args[0] || {}

      dict = options[:dictionary]
      dict ||= {} if options.delete(:use_dictionary)

      kopy = unless dict
        dup()
      else
        find_in_dict_or_dup(dict)
      end

      block.call(self, kopy) if block

      deep_exceptions = {}
      if options[:except]
        exceptions = options[:except].nil? ? [] : [options[:except]].flatten
        exceptions.each do |attribute|
          dup_default_attribute_value_to(kopy, attribute, self) unless attribute.kind_of?(Hash)
        end
        deep_exceptions = exceptions.select{|e| e.kind_of?(Hash) }.inject({}){|m,h| m.merge(h) }
      end

      deep_onlinesses = {}
      if options[:only]
        onlinesses = options[:only].nil? ? [] : [options[:only]].flatten
        object_attrs = kopy.attributes.keys.collect{ |s| s.to_sym }
        exceptions = object_attrs - onlinesses
        exceptions.each do |attribute|
          dup_default_attribute_value_to(kopy, attribute, self) unless attribute.kind_of?(Hash)
        end
        deep_onlinesses = onlinesses.select{|e| e.kind_of?(Hash) }.inject({}){|m,h| m.merge(h) }
      end

      if options[:include]
        Array(options[:include]).each do |association, conditions_or_deep_associations|
          conditions = {}

          if association.kind_of? Hash
            conditions_or_deep_associations = association[association.keys.first]
            association = association.keys.first
          end

          if conditions_or_deep_associations.kind_of?(Hash)
            conditions[:if]     = conditions_or_deep_associations.delete(:if)     if conditions_or_deep_associations[:if]
            conditions[:unless] = conditions_or_deep_associations.delete(:unless) if conditions_or_deep_associations[:unless]
          elsif conditions_or_deep_associations.kind_of?(Array)
            conditions_or_deep_associations.delete_if {|entry| conditions.merge!(entry) if entry.is_a?(Hash) && (entry.key?(:if) || entry.key?(:unless)) }
          end

          dup_options = conditions_or_deep_associations.blank? ? {} : {:include => conditions_or_deep_associations}
          dup_options.merge!(:except => deep_exceptions[association]) if deep_exceptions[association]
          dup_options.merge!(:only => deep_onlinesses[association]) if deep_onlinesses[association]
          dup_options.merge!(:dictionary => dict) if dict

          association_reflection = self.class.reflect_on_association(association)
          raise AssociationNotFoundException.new("#{self.class}##{association}") if association_reflection.nil?

          if options[:validate] == false
            kopy.instance_eval do
              # Force :validate => false on all saves.
              def perform_validations(options={})
                options[:validate] = false
                super(options)
              end
            end
          end

          association_type = association_reflection.macro
          association_type = "#{association_type}_through" if association_reflection.is_a?(ActiveRecord::Reflection::ThroughReflection)

          duped_object = send(
            "dup_#{association_type}_association",
            { :reflection => association_reflection, :association => association, :copy => kopy, :conditions => conditions, :dup_options => dup_options },
            &block
          )

          kopy.send("#{association}=", duped_object)
        end
      end

      return kopy
    end

  protected

    def find_in_dict_or_dup(dict, dup_on_miss = true)
      tableized_class = self.class.name.tableize.to_sym
      dict[tableized_class] ||= {}
      dict_val = dict[tableized_class][self]
      dict_val.nil? && dup_on_miss ? dict[tableized_class][self] = dup() : dict_val
    end

  private

    def dup_default_attribute_value_to(kopy, attribute, origin)
      kopy[attribute] = origin.class.column_defaults.dup[attribute.to_s]
    end

    def dup_belongs_to_association options, &block
      object = self.send(options[:association])
      object = nil if options[:conditions].any? && evaluate_conditions(object, options[:conditions])
      object && object.deep_clone(options[:dup_options], &block)
    end

    def dup_has_one_association options, &block
      dup_belongs_to_association options, &block
    end

    def dup_has_many_association options, &block
      primary_key_name = options[:reflection].foreign_key.to_s

      reverse_association_name = options[:reflection].klass.reflect_on_all_associations.detect do |reflection|
        reflection.foreign_key.to_s == primary_key_name && reflection != options[:reflection]
      end.try(:name)

      objects = self.send(options[:association])
      objects = objects.select{|object| evaluate_conditions(object, options[:conditions]) } if options[:conditions].any?

      objects.collect do |object|
        tmp = object.deep_clone(options[:dup_options], &block)
        tmp.send("#{primary_key_name}=", nil)
        tmp.send("#{reverse_association_name.to_s}=", options[:copy]) if reverse_association_name
        tmp
      end
    end

    def dup_has_many_through_association options, &block
      dup_join_association(
        options.merge(:macro => :has_many, :primary_key_name => options[:reflection].through_reflection.foreign_key.to_s),
        &block)
    end

    def dup_has_and_belongs_to_many_association options, &block
      dup_join_association(
        options.merge(:macro => :has_and_belongs_to_many, :primary_key_name => options[:reflection].foreign_key.to_s),
        &block)
    end

    def dup_join_association options, &block
      reverse_association_name = options[:reflection].klass.reflect_on_all_associations.detect do |reflection|
        (reflection.macro == options[:macro]) && (reflection.association_foreign_key.to_s == options[:primary_key_name])
      end.try(:name)

      objects = self.send(options[:association])
      objects = objects.select{|object| evaluate_conditions(object, options[:conditions]) } if options[:conditions].any?

      objects.collect do |object|
        dict = options[:dup_options][:dictionary]
        if(dict && object.find_in_dict_or_dup(dict, false))
          object = object.deep_clone(options[:dup_options], &block)
        else
          object.send(reverse_association_name).target << options[:copy] if reverse_association_name
        end
        object
      end
    end

    def evaluate_conditions object, conditions
      (conditions[:if] && conditions[:if].call(object)) || (conditions[:unless] && !conditions[:unless].call(object))
    end

    class AssociationNotFoundException < StandardError; end

    ActiveRecord::Base.class_eval { protected :initialize_dup } if ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 1
  end

  include DeepCloneable
end
