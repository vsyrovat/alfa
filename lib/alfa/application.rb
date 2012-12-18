require 'alfa/logger'
require 'alfa/config'

Encoding.default_external='utf-8'
Encoding.default_internal='utf-8'

module Alfa

  # Dirty hack. Using constant-hash to store values. Ruby forbid dynamically change constants, but it allow change items of constant-structs
  # 1st using - in rake tasks (see self.load_tasks)
  VARS = {}

  class Application
    private_class_method :new

    include Alfa::ClassInheritance
    inheritable_attributes :config


    def self.config(kwargs={})
      @config ||= Alfa::Config.new
      @config.merge! kwargs
    end


    def self.init!
      @log_file = File.open(File.join(@config[:log][:file]), File::WRONLY | File::APPEND | File::CREAT)
      @logger = Alfa::Logger.new(@log_file)
      str = "Application (pid=#{$$}) started at #{DateTime.now}"
      @logger.info "#{'='*str.length}\n#{str}"
      @logger.info "  PROJECT_ROOT: #{@config[:project_root]}"
      @logger.info "  DOCUMENT_ROOT: #{@config[:document_root]}\n"
      @log_file.flush
      ObjectSpace.define_finalizer(@logger, Proc.new {@logger.info "Application (pid=#{$$}) stopped at #{DateTime.now}\n\n"})
      @config[:db].each_value { |db| db[:instance].loggers = [@logger] }
      @inited = true
    end


    def self.load_tasks
      VARS[:rakeapp_instance] = self
      require 'alfa/tasks'
    end

  end
end
