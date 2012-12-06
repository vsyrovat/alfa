require 'rbconfig'
require 'alfa/support'
require 'alfa/exceptions'
require 'alfa/application'
require 'alfa/tfile'

module Alfa
  class CliApplication < Alfa::Application
    def self.load_tasks
      Kernel.load 'alfa/tasks/assets.rake'
    end
  end
end