require 'logger'
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
      @log_file = File.open(File.join(@config[:project_root], 'log/dev.log'), File::WRONLY | File::APPEND | File::CREAT)
      #@log_file.sync = true if @config[:run_mode] == :development || @config[:run_mode] == :test
      @logger = Logger.new(@log_file)
      str = "Application (pid=#{$$}) started at #{DateTime.now}"
      @logger << "#{'='*str.length}\n#{str}\n"
      @logger << "  PROJECT_ROOT: #{@config[:project_root]}\n  DOCUMENT_ROOT: #{@config[:document_root]}\n\n"
      @log_file.flush
      ObjectSpace.define_finalizer(@logger, Proc.new {@logger << "Application (pid=#{$$}) stopped at #{DateTime.now}\n\n\n"})
      @inited = true
    end

    def self.load_database path
      Kernel.require path
    end

  end
end
