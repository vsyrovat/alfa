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