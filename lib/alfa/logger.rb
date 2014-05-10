require 'logger'
require 'weakref'
require 'alfa/support'

module Alfa
  class NullLogger
    def portion(*args, &block)
      l = self.class.new
      yield(l)
    end

    def info(*args)
    end

    def debug(*args)
    end

    def <<(*args)
    end
  end


  class Logger < ::Logger

    def initialize(logdev)
      super(nil)
      @logdev = logdev
      @formatter = Formatter.new
    end

    def portion(kwargs={}, &block)
      io = VirtualIO.new
      l = Logger.new(io)
      l.formatter = @formatter
      l.level = @level
      yield(l)
      self << io.join
      flush if kwargs[:sync]
    end

    def flush
      @logdev.flush #if @logdev.respond_to?(:flush)
    end

    private

    class VirtualIO < ::Array
      def write(message)
        self.push message
      end

      def close
      end

      def flush
      end
    end

    class Formatter < ::Logger::Formatter
      def call(severity, time, progname, msg)
        msg2str("#{msg}\n")
      end
    end
  end
end