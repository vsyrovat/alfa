require 'alfa/wrapper'

module Alfa
  class Controller
    attr_accessor :application, :request, :config, :app_sym, :c_sym

    include Alfa::WrapperMethods
  end
end
