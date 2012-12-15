require 'alfa/cli_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)
require File.expand_path('../config', __FILE__)

module Project
  class CliApplication < Alfa::CliApplication
    @config.merge! BASE_CONFIG
    @config[:run_mode] = :cli # :cli for command-line application
    @config[:log][:file] = File.join(PROJECT_ROOT, 'log/cli.log')
  end

  CliApplication.init!
end
