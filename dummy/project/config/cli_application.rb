require 'bundler/setup'
require 'alfa/cli_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)
require File.expand_path('../groups', __FILE__)

module Project
  class CliApplication < Alfa::CliApplication
    instance_eval(File.read(File.expand_path('../config.rb', __FILE__)), File.expand_path('../config.rb', __FILE__))
    config[:run_mode] = :cli # :cli for command-line application
    config[:log][:file] = File.join(PROJECT_ROOT, 'log/cli.log')
  end

  CliApplication.init!
end
