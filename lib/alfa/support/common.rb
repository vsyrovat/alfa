require 'bigdecimal'

module Alfa

  # Thanks to John
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

      def inherited(subclass) # ruby hook
        @inheritable_attributes.each do |inheritable_attribute|
          instance_var = "@#{inheritable_attribute}"
          subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
        end
      end
    end
  end

  module Support
    extend self

    def camelcase_name(arg)
      arg.to_s.split('/').last.split('_').map(&:capitalize).join
    end

    def underscore_name(arg)
      arg.to_s.split('/').last.scan(/[A-Z][a-z]*|[a-z]+|\d+/).map(&:downcase).join('_')
    end

    def args_kwargs(*args)
      return args[0..-2], args.last if args.last.is_a?(Hash)
      return args, {}
    end
  end

end


class Module
  def load_in_module_context file
    module_eval ::File.read(file), file
  end

  def load_in_class_context file
    class_eval ::File.read(file), file
  end
end


class BasicObject
  def load_in_instance_context(file)
    raise LoadError.new("#{file} does not exists") unless ::File.exist?(file)
    instance_eval ::File.read(file), file
  end
end

# Borrowed from active_support/core_ext/hash/keys.rb
class Hash
  # Return a new hash with all keys converted to strings.
  #
  #   { :name => 'Rob', :years => '28' }.stringify_keys
  #   #=> { "name" => "Rob", "years" => "28" }
  def stringify_keys
    dup.stringify_keys!
  end

  # Destructively convert all keys to strings. Same as
  # +stringify_keys+, but modifies +self+.
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end

  # Return a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+.
  #
  #   { 'name' => 'Rob', 'years' => '28' }.symbolize_keys
  #   #=> { :name => "Rob", :years => "28" }
  def symbolize_keys
    dup.symbolize_keys!
  end

  # Destructively convert all keys to symbols, as long as they respond
  # to +to_sym+. Same as +symbolize_keys+, but modifies +self+.
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end


  def delete!(*keys)
    keys.each{|key| self.delete(key)}
    self
  end


  def except(*keys)
    self.dup.delete!(*keys)
  end
end


class String
  # PHP's two argument version of strtr
  def strtr(replace_pairs)
    keys = replace_pairs.map {|a, b| a }
    values = replace_pairs.map {|a, b| b }
    self.gsub(
        /(#{keys.map{|a| Regexp.quote(a) }.join( ')|(' )})/
    ) { |match| values[keys.index(match)] }
  end

  def strtr!(replace_pairs)
    keys = replace_pairs.map {|a, b| a }
    values = replace_pairs.map {|a, b| b }
    self.gsub!(
        /(#{keys.map{|a| Regexp.quote(a) }.join( ')|(' )})/
    ) { |match| values[keys.index(match)] }
  end
end


module Alfa
  module HMround
    # hround(digits) -> string
    #
    # Returns string with human-adopted representation of number, rounded to digit after dot
    #
    #   123.456.hround(1) #=> "123.5"
    #   123.hround(1)     #=> "123"
    #   0.123.hround(1)   #=> "0.1"
    #
    # @param digits Fixnum
    # @return String
    def hround(digits)
      '%g' % ("%.#{digits}f" % self)
    end

    # mround -> string
    #
    # Return string with money representation of number
    #
    #   123.456.mround    #=> "123.46"
    #   123.mround        #=> "123"
    #   123.mround(true)  #=> "123.00"
    #   0.123.mround      #=> "0.12"
    #   1.1.mround        #=> "1.10"
    #
    # @param zeroes Boolean
    # @return String
    def mround(zeroes = false)
      if !zeroes
        y = self.round(2)
        y.modulo(1) == 0 ? y.to_i.to_s : '%.2f' % y
      else
        '%.2f' % self
      end
    end
  end
end


class Fixnum
  include Alfa::HMround
end

class Float
  include Alfa::HMround
end

class String
  include Alfa::HMround
end

class BigDecimal
  include Alfa::HMround
end
