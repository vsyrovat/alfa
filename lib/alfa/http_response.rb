module Alfa
  class HttpResponse
    attr_accessor :code, :headers, :type, :render

    def initialize
      @headers = {}
      @type = :html
    end
  end
end