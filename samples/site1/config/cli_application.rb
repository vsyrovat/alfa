require 'alfa/cli_application'
require File.expand_path('../env', __FILE__)

class CliApplication < Alfa::CliApplication; end
CliApplication.init!