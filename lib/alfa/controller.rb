require 'alfa/wrapper'

module Alfa
  class Controller
    include Alfa::WrapperMethods

    attr_accessor :application, :request, :config, :app_sym, :c_sym, :params, :resourcer, :route, :response

    def initialize(route: nil)
      @route = route
    end
  end
end
