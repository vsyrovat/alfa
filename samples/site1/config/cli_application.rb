require 'alfa/cli_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)

module Project
  class CliApplication < Alfa::CliApplication
    config[:run_mode] = :cli # :cli for command-line application
    config[:project_root] = PROJECT_ROOT
    config[:document_root] = DOCUMENT_ROOT
    config[:log][:file] = File.join(PROJECT_ROOT, 'log/cli.log')
    config[:db][:main] = DB::Main
  end

  CliApplication.init!
end
