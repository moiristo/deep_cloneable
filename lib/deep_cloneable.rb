class ActiveRecord::Base
  module DeepCloneable
    # ActiveRecord::Base has its own dup method for Ruby 1.8.7. We have to
    # redefine it and put it in a module so that we can override it in a
    # module and call the original with super().
    if !Object.respond_to? :initialize_dup
      ActiveRecord::Base.class_eval do
        module Dup
          def dup
            copy = super
            copy.initialize_dup(self)
            copy
          end
        end
        remove_method :dup
        include Dup
      end
    end

    # clones an ActiveRecord model.
    # if passed the :include option, it will deep clone the given associations
    # if passed the :except option, it won't clone the given attributes
    #
    # === Usage:
    #
    # ==== Cloning one single association
    #    pirate.clone :include => :mateys
    #
    # ==== Cloning multiple associations
    #    pirate.clone :include => [:mateys, :treasures]
    #
    # ==== Cloning really deep
    #    pirate.clone :include => {:treasures => :gold_pieces}
    #
    # ==== Cloning really deep with multiple associations
    #    pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
    #
    # ==== Cloning really deep with multiple associations and a dictionary
    #
    # A dictionary ensures that models are not cloned multiple times when it is associated to nested models.
    # When using a dictionary, ensure recurring associations are cloned first:
    #
    #    pirate.clone :include => [:mateys, {:treasures => [:matey, :gold_pieces], :use_dictionary => true }]
    #
    # If this is not an option for you, it is also possible to populate the dictionary manually in advance:
    #
    #    dict = { :mateys => {} }
    #    pirate.mateys.each{|m| dict[:mateys][m] = m.clone }
    #    pirate.clone :include => [:mateys, {:treasures => [:matey, :gold_pieces], :dictionary => dict }]
    #
    # ==== Cloning a model without an attribute
    #    pirate.clone :except => :name
    #
    # ==== Cloning a model without multiple attributes
    #    pirate.clone :except => [:name, :nick_name]
    #
    # ==== Cloning a model without an attribute or nested multiple attributes
    #    pirate.clone :include => :parrot, :except => [:name, { :parrot => [:name] }]
    #
    define_method :dup do |*args, &block|
      options = args[0] || {}

      dict = options[:dictionary]
      dict ||= {} if options.delete(:use_dictionary)

      kopy = unless dict
        super()
      else
        tableized_class = self.class.name.tableize.to_sym
        dict[tableized_class] ||= {}
        dict[tableized_class][self] ||= super()
      end

      exceptions = []

      if options[:except]
        exceptions = options[:except].nil? ? [] : [options[:except]].flatten
        deep_exceptions = {}
      end

      exceptions.each do |attribute|
        kopy.send(:instance_variable_set, attribute, nil) if kopy.send(:instance_variables).include? attribute
      end

      block.call(self, kopy) if block

      exceptions.each do |attribute|
        kopy.send(:write_attribute, attribute, self.class.column_defaults.dup[attribute.to_s]) unless attribute.kind_of? Hash
        deep_exceptions = exceptions.select{|e| e.kind_of?(Hash) }.inject({}){|m,h| m.merge(h) }
      end

      if options[:include]
        Array(options[:include]).each do |association, deep_associations|
          if (association.kind_of? Hash)
            deep_associations = association[association.keys.first]
            association = association.keys.first
          end

          opts = deep_associations.blank? ? {} : {:include => deep_associations}
          opts.merge!(:except => deep_exceptions[association]) if deep_exceptions[association]
          opts.merge!(:dictionary => dict) if dict

          association_reflection = self.class.reflect_on_association(association)
          raise AssociationNotFoundException.new("#{self.class}##{association}") if association_reflection.nil?

          cloned_object = case association_reflection.macro
            when :belongs_to, :has_one
              self.send(association) && self.send(association).send(__method__, opts, &block)
            when :has_many
              primary_key_name = association_reflection.foreign_key.to_s

              reverse_association_name = association_reflection.klass.reflect_on_all_associations.detect do |a|
                a.foreign_key.to_s == primary_key_name
              end.try(:name)

              self.send(association).collect do |obj|
                tmp = obj.send(__method__, opts, &block)
                tmp.send("#{primary_key_name}=", nil)
                tmp.send("#{reverse_association_name.to_s}=", kopy) if reverse_association_name
                tmp
              end
            when :has_and_belongs_to_many
              primary_key_name = association_reflection.foreign_key.to_s

              reverse_association_name = association_reflection.klass.reflect_on_all_associations.detect do |a|
                (a.macro == :has_and_belongs_to_many) && (a.association_foreign_key.to_s == primary_key_name)
              end.try(:name)

              self.send(association).collect do |obj|
                obj.send(reverse_association_name).target << kopy
                obj
              end
          end

          kopy.send("#{association}=", cloned_object)
        end
      end

      return kopy
    end

    class AssociationNotFoundException < StandardError; end
  end

  include DeepCloneable
end
