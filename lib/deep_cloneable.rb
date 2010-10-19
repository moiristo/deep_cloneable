class ActiveRecord::Base
  module DeepCloneable
    # clones an ActiveRecord model. 
    # if passed the :include option, it will deep clone the given associations
    # if passed the :except option, it won't clone the given attributes
    #
    # === Usage:
    # 
    # ==== Cloning a model without an attribute
    #   pirate.clone :except => :name
    # 
    # ==== Cloning a model without multiple attributes
    #   pirate.clone :except => [:name, :nick_name]
    # ==== Cloning one single association
    #   pirate.clone :include => :mateys
    #
    # ==== Cloning multiple associations
    #   pirate.clone :include => [:mateys, :treasures]
    #
    # ==== Cloning really deep
    #   pirate.clone :include => {:treasures => :gold_pieces}
    #
    # ==== Cloning really deep with multiple associations
    #   pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
    # 
    def clone(options = {})
      kopy = super()
    
      deep_exceptions = {}
      if options[:except]
        exceptions = Array(options[:except])
        exceptions.each do |attribute|
          kopy.send(:write_attribute, attribute, attributes_from_column_definition[attribute.to_s]) unless attribute.kind_of?(Hash)
        end
        deep_exceptions = exceptions.select{|e| e.kind_of?(Hash) }.inject({}){|m,h| m.merge(h) }
      end
    
      if options[:include]
        Array(options[:include]).each do |association, deep_associations|
          if (association.kind_of? Hash)
            deep_associations = association[association.keys.first]
            association = association.keys.first
          end
          
          opts = deep_associations.blank? ? {} : {:include => deep_associations}
          opts.merge!(:exclude => deep_exceptions[association]) if deep_exceptions[association]
      
          association_reflection = self.class.reflect_on_association(association)          
          cloned_object = case association_reflection.macro
                          when :belongs_to, :has_one
                            self.send(association) && self.send(association).clone(opts)
                          when :has_many, :has_and_belongs_to_many
                            fk = association_reflection.options[:foreign_key] || self.class.to_s.underscore
                            self.send(association).collect do |obj| 
                              tmp = obj.clone(opts)
                              tmp.send("#{fk}=", kopy)
                              tmp
                            end
                          end
          kopy.send("#{association}=", cloned_object)
        end
      end

      return kopy
    end
  end
  
  include DeepCloneable
end