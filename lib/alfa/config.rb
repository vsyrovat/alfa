module Alfa
  class Config < ::Hash

    def initialize
      self[:db] = {}
      self[:log] = {}
      self[:session] = {key: 'session', secret: nil}
    end

    def []=(key, value)
      if [:db, :log, :session].include? key
        raise "key :#{key} should include Enumerable" unless value.class.included_modules.include? Enumerable
      end
      super
    end

    def store(key, value)
      if [:db, :log, :session].include? key
        raise "key :#{key} should include Enumerable" unless value.class.included_modules.include? Enumerable
      end
      super
    end

  end
end
