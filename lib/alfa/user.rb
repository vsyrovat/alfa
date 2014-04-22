module Alfa
  class << self
    attr_accessor :GROUPS
  end

  class GuestUser
    def self.grants
      @grants ||= Alfa.GROUPS[:public]
    end

    def self.grant?(name)
      grants.include?(name.to_sym)
    end

    def self.groups
      []
    end

    def self.group?(name)
      groups.include?(name.to_sym)
    end

    def self.logged?
      false
    end

    def [](key)
      nil
    end

    def method_missing(key)
      nil
    end
  end


  class User
    def initialize(object)
      @object = object
    end

    def grants
      (groups + [:public]).map{|g| Alfa.GROUPS[g] || []}.flatten
    end

    def grant?(name)
      grants.include?(name.to_sym)
    end

    # @return Array
    def groups
      @object.groups.map{|s| s.strip.to_sym}
    end

    def group?(name)
      groups.include?(name.to_sym)
    end

    def logged?
      true
    end

    def [](key)
      @object[key]
    end

    def method_missing(*o)
      @object.send(*o)
    end

    def self.method_missing(*o)
      @object.class.send(*o)
    end
  end
end