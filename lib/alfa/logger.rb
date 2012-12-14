require 'logger'

module Alfa
  class Logger < ::Logger

    def initialize(logdev, shift_age = 0, shift_size = 1048576)
      super
      @formatter = Formatter.new
    end

    def portion(&block)
      io = VirtualIO.new
      l = ::Logger.new(io)
      l.formatter = @formatter
      yield(l)
      self << io.join
      l = nil
      io = nil
    end

    private

    class VirtualIO < ::Array
      def write(message)
        self.push message
      end

      def close
      end
    end

    class Formatter < ::Logger::Formatter
      def call(severity, time, progname, msg)
        msg2str("#{msg}\n")
      end
    end
  end
end