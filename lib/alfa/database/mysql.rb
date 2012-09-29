require 'alfa/support'
require 'mysql2'

module Alfa
  module Database
    class MySQL
      include Alfa::ClassInheritance
      inheritable_attributes :host, :port, :user, :password, :dbname, :client
      @host = nil
      @port = 3306
      @user = nil
      @password = nil
      @dbname = nil
      @client = nil

      def self.check_params
        raise ":host must be defined for #{self.to_s}" unless @host
        raise ":user must be defined for #{self.to_s}" unless @user
        raise ":password must be defined for #{self.to_s}" unless @password
        raise ":dbname must be defined for #{self.to_s}" unless @dbname
      end

      def self.query query
        begin
          self.client.query(query)
        rescue Mysql2::Error => e
          raise "#{e.message} (query: \"#{query}\", error number: #{e.error_number}, sql state: #{e.sql_state})"
        end
      end

      def self.client
        unless @client
          self.check_params
          @client = Mysql2::Client.new(:host=>@host, :username=>@user)
          @client.query_options.merge!(:symbolize_keys => true, :as => :hash, :database_timezone => :utc, :application_timezone => :utc)
          @client.query "SET NAMES utf8"
          @client.query "USE #{@dbname}"
        end
        @client
      end

      def self.transaction &block
        begin
          self.query "START TRANSACTION"
          yield
        rescue
          self.query "ROLLBACK"
        else
          self.query "COMMIT"
        end
      end

    end
  end
end