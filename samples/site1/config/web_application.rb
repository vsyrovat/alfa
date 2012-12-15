require 'alfa/web_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)

module Project
  class WebApplication < Alfa::WebApplication
    config[:run_mode] = :development # :development or :production or :test
    config[:project_root] = PROJECT_ROOT
    config[:document_root] = DOCUMENT_ROOT
    config[:log][:file] = File.join(PROJECT_ROOT, 'log/web.log')
    config[:db][:main] = DB::Main
  end

  WebApplication.init!
end
