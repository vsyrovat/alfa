module Alfa
  class Snippeter
    @snippets = {}
    @config = {}
    @cursor = nil

    class << self
      attr_accessor :config
      attr_writer :mounts
    end

    # @param Symbol app
    def self.load
      @mounts.each do |m|
        app = m[:app]
        path = File.join(@config[:project_root], 'apps', app.to_s, 'snippets.rb')
        @cursor = app
        @snippets[@cursor] ||= {}
        if File.exist?(path)
          load_in_instance_context path
        end
      end
    end

    # @param Symbol name
    # @param Proc &block
    def self.snippet(name, &block)
      raise 'Snippet name should be a Symbol' unless name.is_a?(Symbol)
      raise 'Snippets requires scope' unless @cursor
      @snippets[@cursor][name] = block
    end


    def self.[](name)
      if @config[:run_mode] == :development
        @snippets.clear
        self.load
      end
      @snippets[name]
    end
  end
end