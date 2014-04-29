require 'alfa/wrapper'

module Alfa
  class Controller
    include Alfa::WrapperMethods

    attr_accessor :application, :request, :config, :app_sym, :c_sym, :params

    def initialize(route: nil)
      @route = route
    end

    def self.__options
      @__options ||= {}
    end

    def render(type)
      m = caller_locations(1, 1)[0].label.to_sym
      self.class.options(m, {render: type})
    end

    def self.options(method, opts)
      __options[method.to_sym] = __options[method.to_sym] ? __options[method.to_sym].merge(opts) : opts
    end

    def self.get_content_type(method)
      o = __options[method]
      o.is_a?(Hash) ? o[:content_type] : nil
    end

    def self.get_render(method)
      o = __options[method]
      o.is_a?(Hash) ? o[:render] : nil
    end
  end
end
