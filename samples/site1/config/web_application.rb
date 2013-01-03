require 'alfa/web_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)

module Project
  class WebApplication < Alfa::WebApplication
    instance_eval(File.read(File.expand_path('../config.rb', __FILE__)), File.expand_path('../config.rb', __FILE__))
    config[:run_mode] = :development # :development or :production or :test
    config[:log][:file] = File.join(PROJECT_ROOT, 'log/web.log')
    config[:serve_static] = true
  end

  WebApplication.init!
end
