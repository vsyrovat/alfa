require 'alfa/logger'
require 'alfa/config'
require 'alfa/exceptions'
require 'alfa/user'
require 'scrypt'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module Alfa

  # Dirty hack. Using constant-hash to store values. Ruby forbid dynamically change constants, but it allow change items of constant-structs
  # 1st using - in Rake tasks (see self.load_tasks)
  VARS = {}

  class Application
    private_class_method :new

    include ClassInheritance
    inheritable_attributes :config

    @config = Alfa::Config.new

    def self.config(kwargs = nil)
      @config.merge!(kwargs) if kwargs
      @config
    end


    def self.init!
      self.verify_config
      if @config[:log][:file]
        @log_file = File.open(@config[:log][:file], File::WRONLY | File::APPEND | File::CREAT)
        @logger = Alfa::Logger.new(@log_file)
        str = "Application (pid=#{$$}) started in #{@config[:run_mode]} mode at #{DateTime.now}"
        @logger.info "#{'='*str.length}\n#{str}"
        @logger.info "  PROJECT_ROOT: #{@config[:project_root]}"
        @logger.info "  DOCUMENT_ROOT: #{@config[:document_root]}\n"
        @log_file.flush
        ObjectSpace.define_finalizer(@logger, Proc.new {@logger.info "Application (pid=#{$$}) stopped at #{DateTime.now}\n\n"})
        @config[:db].each_value { |db| db[:instance].logger = @logger }
      else
        @logger = Alfa::NullLogger.new
      end
      @inited = true
    end


    def self.load_tasks
      VARS[:rakeapp_instance] = self
      require 'alfa/tasks'
      Dir[File.join(@config[:project_root], 'tasks', '*.rake')].each do |f|
        Kernel.load f
      end
    end


    def self.verify_config
      raise Exceptions::E001.new('config[:project_root] should be defined') unless @config[:project_root]
    end


    def self.try_register(login, password)
      @config[:db][:main][:instance].transaction do
        unless ::User.first(:login=>login)
          @logger.portion do |l|
            passhash = SCrypt::Password.create(password)
            ::User.create(:login=>login, :passhash=>passhash)
            l.info("created new user login=#{login}, passhash=#{passhash}")
          end
          return true, "Registration done"
        end
        return false, "User with login #{login} already exists"
      end
    end
  end
end
