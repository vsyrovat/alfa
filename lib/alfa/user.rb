module Alfa
  class GuestUser
    def self.grants
      []
    end

    def self.grant?(name)
      grants.include?(name.to_sym)
    end

    def self.groups
      [:public]
    end

    def self.group?(name)
      groups.include?(name.to_sym)
    end
  end

  class User
    def initialize(properties)
      @properties = properties
    end

    def grants
      []
    end

    def grant?(name)
      grants.include?(name.to_sym)
    end

    def groups
      []
    end

    def group?(name)
      groups.include?(name.to_sym)
    end
  end
end