require 'rack/file'

module Alfa
  module Rack
    class File < ::Rack::File
      # Deny .htaccess files
      def call(env)
        return fail(404, 'Not found') if env['PATH_INFO'].split(SEPS).last == '.htaccess'
        super
      end
    end
  end
end