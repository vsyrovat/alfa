require 'alfa/support'
require 'alfa/database/mysql'
require 'alfa/models/base_sql'

module Alfa
  module Models
    class MySQL < Alfa::Models::BaseSQL
      include Alfa::ClassInheritance
      inheritable_attributes :connection, :table
      @connection = nil
      @table = nil
      @pk = :id

      def self.register_database database
        raise 'Expected database to be instance of Alfa::Database::MySQL' unless database.ancestors.include? Alfa::Database::MySQL
        @connection = database
      end

      #@return Array || nil
      def self.all
        @connection.query("SELECT * FROM `#{self.table}`")
      end

      def self.find filter = {}

      end

      def self.find_first filter = {}
      end

      def self.count filter = {}
      end

      def self.exists? pk
      end

      def self.create data = {}
      end

      def self.delete pk
      end

      def self.update data = {}
      end

      def self.table
        @table.to_s
      end

    end
  end
end