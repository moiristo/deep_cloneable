class ActiveRecord::Base
  module DeepCloneable
    # ActiveRecord::Base has its own dup method for Ruby 1.8.7. We have to
    # redefine it and put it in a module so that we can override it in a
    # module and call the original with super().
    unless Object.respond_to?(:initialize_dup, true)
      ActiveRecord::Base.class_eval do
        module Dup
          def dup
            copy = super
            copy.send(:initialize_dup, self)
            copy
          end
        end
        remove_possible_method :dup
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
    def dup *args, &block
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

      block.call(self, kopy) if block

      deep_exceptions = {}
      if options[:except]
        exceptions = options[:except].nil? ? [] : [options[:except]].flatten
        exceptions.each do |attribute|
          kopy.send(:write_attribute, attribute, self.class.column_defaults.dup[attribute.to_s]) unless attribute.kind_of?(Hash)
        end
        deep_exceptions = exceptions.select{|e| e.kind_of?(Hash) }.inject({}){|m,h| m.merge(h) }
      end

      if options[:include]
        Array(options[:include]).each do |association, deep_associations|
          if (association.kind_of? Hash)
            deep_associations = association[association.keys.first]
            association = association.keys.first
          end

          dup_options = deep_associations.blank? ? {} : {:include => deep_associations}
          dup_options.merge!(:except => deep_exceptions[association]) if deep_exceptions[association]
          dup_options.merge!(:dictionary => dict) if dict
          dup_options.merge!(:dup_habtm => options[:dup_habtm]) if options[:dup_habtm]

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

          association_method =
            if association_reflection.options[:through]
              "dup_#{association_reflection.macro}_through"
            else
              "dup_#{association_reflection.macro}_association"
            end

          cloned_object = send(
            association_method,
            { :reflection => association_reflection, :association => association, :copy => kopy, :dup_options => dup_options },
            &block
          )

          kopy.send("#{association}=", cloned_object)
        end
      end

      return kopy
    end
    
  private
  
    def dup_belongs_to_association options, &block
      self.send(options[:association]) && self.send(options[:association]).dup(options[:dup_options], &block)
    end  
  
    def dup_has_one_association options, &block
      dup_belongs_to_association options, &block
    end
    
    def dup_has_many_association options, &block
      primary_key_name = options[:reflection].foreign_key.to_s

      reverse_association_name = options[:reflection].klass.reflect_on_all_associations.detect do |reflection|
        reflection.foreign_key.to_s == primary_key_name && reflection != options[:reflection]
      end.try(:name)

      self.send(options[:association]).collect do |obj|
        tmp = obj.dup(options[:dup_options], &block)
        tmp.send("#{primary_key_name}=", nil)
        tmp.send("#{reverse_association_name.to_s}=", options[:copy]) if reverse_association_name
        tmp
      end      
    end
        
    def dup_has_many_through options, &block
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

      self.send(options[:association]).collect do |obj|
        if options[:dup_options][:dup_habtm]
          obj = obj.dup(options[:dup_options], &block)
        else
          obj.send(reverse_association_name).target << options[:copy]
        end
        obj
      end
    end
    
    class AssociationNotFoundException < StandardError; end
  end

  include DeepCloneable
end
