require 'rack/file'

module Rack
  class FileAlfa < File
    #Deny .htaccess files
    def call(env)
      return fail(404, 'Not found') if env['PATH_INFO'].split(SEPS).last == '.htaccess'
      super
    end
  end
end
