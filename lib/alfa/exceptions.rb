module Alfa
  module Exceptions
    # Route not found
    class Route404 < StandardError; end

    # Application's config.project_root required
    class E001 < StandardError; end

    # WebApplication's config.document_root required
    class E002 < StandardError; end

    # Href can't be build
    class E003 < StandardError; end
  end
end
