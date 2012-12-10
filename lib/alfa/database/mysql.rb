require 'alfa/support'
require 'mysql2'
require 'alfa/models/mysql'
require 'alfa/query_logger'
require 'yaml'

module Alfa
  module Database
    class MySQL
      include Alfa::ClassInheritance
      inheritable_attributes :host, :port, :user, :password, :dbname, :client, :config, :schema_path, :encondig
      @host = nil
      @port = 3306
      @user = nil
      @password = nil
      @dbname = nil
      @client = nil
      @config = nil
      @schema_path = nil
      @encoding = nil

      def self.load_schema path
        @schema_path = path
        data = YAML::load File.open(File.join(path, 'schema.yml'))
        data.symbolize_keys!
        @encoding = data[:encoding] if data[:encoding]
        raise "Unacceptible engine in #{path}/schema.yml, expected to be mysql of mysql2" unless ['mysql', 'mysql2'].include? data[:engine]
        Dir[File.join(path, 'models/*.rb')].each do |file|
          require file
          Kernel::const_get(Alfa::Support.capitalize_name(File.basename(file, '.rb'))).register_database self
        end

      end

      def self.load_config file
        @config = file
        data = YAML::load File.open(file)
        data.symbolize_keys!
        @host = data[:host] if data[:host]
        @port = data[:port] if data[:port]
        @user = data[:user] if data[:user]
        @password = data[:password] if data[:password]
        @dbname = data[:dbname] if data[:dbname]
      end

      def self.check_params
        raise ":host must be defined for #{self.to_s}" unless @host
        raise ":user must be defined for #{self.to_s}" unless @user
        raise ":password must be defined for #{self.to_s}" unless @password
        raise ":dbname must be defined for #{self.to_s}" unless @dbname
        raise ":encoding must be defined for #{self.to_s}" unless @encoding
      end

      def self.query query
        self.check_client
        begin
          Alfa::QueryLogger.log query, self do
            @client.query(query)
          end
        rescue Mysql2::Error => e
          raise "#{e.message} (query: \"#{query}\", error number: #{e.error_number}, sql state: #{e.sql_state})"
        end
      end

      def self.check_client
        unless @client
          self.check_params
          @client = Mysql2::Client.new(:host=>@host, :username=>@user)
          @client.query_options.merge!(:symbolize_keys => true, :as => :hash, :database_timezone => :utc, :application_timezone => :utc)
          Alfa::QueryLogger.log "SET NAMES utf8", self do
            @client.query "SET NAMES " + @encoding
          end
          Alfa::QueryLogger.log "USE `#@dbname`", self do
            @client.query "USE `#@dbname`"
          end
        end
      end

      def self.transaction &block
        self.check_client
        begin
          self.query "START TRANSACTION"
          yield
        rescue StandardError => e
          self.query "ROLLBACK"
          raise e
        else
          self.query "COMMIT"
        end
      end

      def self.escape arg
        case arg.class
          when Numeric
            arg.to_s
          when Array
            arg.map {|a|
              self.escape(a).to_s
            }.join(',')
          else
            client.escape arg.to_s
        end
      end

    end
  end
end
