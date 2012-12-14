require 'alfa/logger'
require 'alfa/config'

module Alfa
  class Application
    private_class_method :new

    include Alfa::ClassInheritance
    inheritable_attributes :config

    @config = Alfa::Config.new

    def self.config args=nil
      return @config if args.nil?
      @config.merge args
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
      @config[:db].each_value { |db| db.loggers = [@logger] }
      @inited = true
    end

    def self.load_database path
      Kernel.require path
    end

  end
end
