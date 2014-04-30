require 'rack/file'

module Rack
  class FileAlfa < File
    #Deny .htaccess files
    def _call(env)
      return fail(404, 'Not found') if env['PATH_INFO'].split(SEPS).last == '.htaccess'
      @headers['Expires'] = (Time.now + 2592000).httpdate
      super
    end
  end
end
