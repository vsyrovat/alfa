require 'alfa/wrapper'

module Alfa
  class Controller
    attr_accessor :application, :request, :config, :app_sym, :c_sym

    include Alfa::WrapperMethods

    def self.content_types
      @content_types ||= {}
    end

    def self.content_type(method, type)
      content_types[method.to_sym] = type.to_sym
    end

    def self.get_content_type(method)
      content_types[method]
    end
  end
end
