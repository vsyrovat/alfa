module Alfa
  class GuestUser
    def grants
      []
    end

    def grant?(name)
      grants.include?(name.to_sym)
    end

    def groups
      [:public]
    end

    def group?(name)
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