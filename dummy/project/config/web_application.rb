require 'bundler/setup'
require 'alfa/web_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)
require File.expand_path('../groups', __FILE__)

module Project
  class WebApplication < Alfa::WebApplication
    instance_eval(File.read(File.expand_path('../config.rb', __FILE__)), File.expand_path('../config.rb', __FILE__))
    config[:run_mode] = :development # :development or :production or :test
    config[:log][:file] = File.join(PROJECT_ROOT, 'log/web.log')
    config[:serve_static] = true
    config[:session][:secret] = YAML.load(File.open(File.expand_path('../passwords/secrets.yml', __FILE__))).symbolize_keys[:session_secret]
  end

  WebApplication.init!
end
