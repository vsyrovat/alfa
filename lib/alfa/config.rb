module Alfa
  class Config < ::Hash

    def initialize
      self[:db] = {}
      self[:log] = {}
    end

    def []=(key, value)
      if [:db, :log].include? key
        raise "key :#{key} should include Enumerable" unless value.class.included_modules.include? Enumerable
      end
      super
    end

    def store(key, value)
      if [:db, :log].include? key
        raise "key :#{key} should include Enumerable" unless value.class.included_modules.include? Enumerable
      end
      super
    end

  end
end
