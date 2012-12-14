module Alfa
  class Config < ::Hash
    #attr_accessor :project_root, :document_root, :db

    def initialize
      self[:db] = {}
      self[:log] = {}
    end

  end
end
