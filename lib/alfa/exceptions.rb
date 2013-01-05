module Alfa
  module Exceptions
    # Route not found
    class Route404 < StandardError; end

    class HttpRedirect < StandardError
      attr_reader :url, :code
      def initialize(url, code)
        @url, @code = url, code
      end
    end

    # Application's config.project_root required
    class E001 < StandardError; end

    # WebApplication's config.document_root required
    class E002 < StandardError; end

    # Href can't be build
    class E003 < StandardError; end

    # Bad str for href format
    class E004 < StandardError; end
  end
end
