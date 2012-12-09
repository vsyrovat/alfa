require 'alfa/web_application'
require File.expand_path('../env', __FILE__)
require File.expand_path('../db', __FILE__)

class WebApplication < Alfa::WebApplication; end
WebApplication.init!