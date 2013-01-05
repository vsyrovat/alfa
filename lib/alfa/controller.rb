require 'alfa/support'
require 'alfa/exceptions'

module Alfa
  class Controller
    attr_accessor :application, :app_sym, :c_sym

    def _instance_variables_hash
      Hash[instance_variables.map { |name| [name.to_s[1..-1].to_sym, instance_variable_get(name)] } ]
    end

    def _clear_instance_variables
      instance_variables.each {|name| remove_instance_variable(name)}
    end

    def href(*o)
      kwargs = _extract_href_params(*o)
      @application.routes.href(kwargs)
    end

    def _extract_href_params(*o)
      args, kwargs = Support.args_kwargs(*o)
      if args.any?
        if args.first.is_a?(Symbol)
          kwargs[:action] = args.first
        else
          kwargs.merge! _string_to_aca(args.first.to_s)
        end
      end
      kwargs = {:app=>@app_sym}.merge kwargs
      kwargs = {:controller=>@c_sym}.merge kwargs if kwargs[:action]
      kwargs
    end

    # Convert string to App-Controller-Action hash
    # 'app*controller#action'
    def _string_to_aca(str)
      res = {}
      s1 = str.split('*')
      raise Exceptions::E004.new("E004: Bad href argument #{str}: it should contain at most one * symbol") if s1.length > 2
      res[:app] = s1.first.to_sym if s1.length > 1
      s2 = s1.last.split('#')
      raise Exceptions::E004.new("E004: Bad href argument #{str}: it should contain at most one # symbol") if s2.length > 2
      res[:controller] = s2.first.to_sym if s2.length > 1
      res[:action] = s2.last.to_sym
      res
    end
  end
end
