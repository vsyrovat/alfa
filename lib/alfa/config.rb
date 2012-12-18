module Alfa
  class Config < ::Hash

    def initialize
      self[:db] = {}
      self[:log] = {}
    end

  end
end
