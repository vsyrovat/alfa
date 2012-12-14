module Alfa
  class QueryLogger
    @logs = []
    @num = 0
    class << self
      def log query, instance = nil, &block
        @num += 1
        if block_given?
          log = {:num => @num, :query => query, :instance => instance, :status => :started, :error => nil, :logger_hash => self.hash}
          @logs << log
          begin
            result = yield
          rescue StandardError => e
            log[:status] = :fail
            log[:error] = e.message
            raise e
          end
          log[:status] = :done
          return result
        else
          @logs << {:num => @num, :query => query, :instance => instance, :status => :flat, :logger_hash => self.hash}
        end
      end
      def logs
        @logs
      end
    end
  end
end
