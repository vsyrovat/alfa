require 'alfa/web_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)
require File.expand_path('../config', __FILE__)

module Project
  class WebApplication < Alfa::WebApplication
    @config.merge! BASE_CONFIG
    @config[:run_mode] = :development # :development or :production or :test
    @config[:log][:file] = File.join(PROJECT_ROOT, 'log/web.log')
  end

  WebApplication.init!
end
