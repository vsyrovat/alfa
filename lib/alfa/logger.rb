require 'logger'
require 'weakref'
require 'alfa/support'

module Alfa
  class NullLogger
    def portion(*args, &block)
      l = WeakRef.new(self.class.new)
      yield(l)
    end

    def info(*args)
    end

    def <<(*args)
    end
  end


  class Logger < ::Logger

    def initialize(logdev, shift_age = 0, shift_size = 1048576)
      super
      @logdev = logdev
      @formatter = Formatter.new
    end

    def portion(kwargs={}, &block)
      io = VirtualIO.new
      l = Logger.new(io)
      l.formatter = @formatter
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