module Alfa

  # thanks to John
  # http://railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/
  module ClassInheritance
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def inheritable_attributes(*args)
        @inheritable_attributes ||= [:inheritable_attributes]
        @inheritable_attributes += args
        args.each do |arg|
          class_eval %(
            class << self; attr_accessor :#{arg} end
          )
        end
        @inheritable_attributes
      end

      def inherited(subclass)
        @inheritable_attributes.each do |inheritable_attribute|
          instance_var = "@#{inheritable_attribute}"
          subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
        end
      end
    end
  end

  class Support
    def self.capitalize_name arg
      arg.to_s.split('/').last.split('_').map(&:capitalize).join
    end
  end

end


  class Module
    def load_in_module_context file
      module_eval file, file
    end

    def load_in_class_context file
      class_eval file, file
    end
  end

  class BasicObject
    def load_in_instance_context file
      instance_eval file, file
    end
  end

  class Hash
    # Destructively convert all keys to symbols, as long as they respond
    # to +to_sym+. Same as +symbolize_keys+, but modifies +self+.
    def symbolize_keys!
      keys.each do |key|
        self[(key.to_sym rescue key) || key] = delete(key)
      end
      self
    end
  end

