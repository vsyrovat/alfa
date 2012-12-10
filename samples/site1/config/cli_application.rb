require 'alfa/cli_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)

class CliApplication < Alfa::CliApplication; end
CliApplication.init!
