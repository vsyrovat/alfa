require 'alfa/support'
require 'alfa/models/base_sql'

module Alfa
  module Models
    class MySQL < Alfa::Models::BaseSQL
      include Alfa::ClassInheritance
      inheritable_attributes :connection, :table

      @connection = nil
      @table = nil
      @pk = :id

      class << self

        def register_database database
          raise 'Expected database to be instance of Alfa::Database::MySQL' unless database.ancestors.include? Alfa::Database::MySQL
          @connection = database
        end

        #@return Array || nil
        def all
          @connection.query("SELECT * FROM `#{self.table}`")
        end

        def find filter = {}

        end

        def find_first filter = {}
        end

        def count filter = {}
        end

        def exists? pk
        end

        def create data = {}
          #data.symbolize_keys!
          @connection.query("INSERT INTO `#{self.table}` SET #{self.prepare_set_string(data)}")
        end

        def delete pk
        end

        def update data = {}
        end

        def table
          @table.to_s
        end

        def prepare_set_string data = {}
          data.map{|field, value| "`#{@connection.escape(field)}`='#{@connection.escape(value)}'"}.join(', ')
        end

      end

    end
  end
end
