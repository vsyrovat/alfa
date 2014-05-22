require 'alfa/support'
require 'alfa/exceptions'

module Alfa
  module WrapperMethods
    def _instance_variables_hash
      Hash[instance_variables.map { |name| [name.to_sym, instance_variable_get(name)] } ]
    end

    def _clear_instance_variables
      instance_variables.each {|name| remove_instance_variable(name)}
    end

    def href(*o)
      kwargs = _extract_href_params(*o)
      @application.routes.href(kwargs)
    end

    alias :href_to :href

    def _extract_href_params(*o)
      args, kwargs = Support.args_kwargs(*o)
      kwargs.merge!(_string_to_aca(args.first.to_s)) if args.any?
      kwargs = {:app=>@app_sym}.merge kwargs
      kwargs = {:controller=>@c_sym}.merge kwargs if kwargs[:action]
      kwargs[:action] = :index if kwargs[:controller] && !kwargs[:action]
      kwargs
    end

    # Convert string to App-Controller-Action hash
    # 'app*controller#action'
    def _string_to_aca(str)
      res = {}
      s1 = str.split('@')
      raise Exceptions::E004.new("E004: Bad href argument #{str}: it should contain at most one @ symbol") if s1.length > 2
      res[:app] = s1.last.to_sym if s1.length > 1
      s2 = s1.first.split('#', -1)
      raise Exceptions::E004.new("E004: Bad href argument #{str}: it should contain at most one # symbol") if s2.length > 2
      if s2.length > 0
        res[:action] = s2.last.to_sym unless s2.last.empty?
        if s2.length > 1
          res[:controller] = s2.first.to_sym unless s2.first.empty?
        end
      end
      res
    end


    def session
      @request.session
    end

    # Return current user
    def user
      @user ||= (
        if @request.session[:user_id] &&
           (u = ::User.first(id: @request.session[:user_id])) &&
           @request.session[:passhash] == u[:passhash]
          Alfa::User.new(u)
        else
          GuestUser
        end
      )
    end


    def grant?(grant)
      user.grant?(grant)
    end


    [300, 301, 302, 303].each do |code|
      define_method ("redirect_#{code}".to_sym) do |url|
        @application.redirect(url, code)
      end
    end

    alias :redirect :redirect_302


    def try_login(login, password)
      u = @application.config[:db][:main][:instance][:users].first(login: login)
      raise "No such login: #{login}" unless u
      if SCrypt::Password.new(u[:passhash]) == password
        # success
        session[:user_id] = u[:id]
        session[:passhash] = u[:passhash]
        return true
      else
        # fail
        session[:user_id] = nil
        raise 'login fail'
        return false
      end
    end


    def try_register(login, password)
      @application.try_register(login, password)
    end


    def try_logout
      session[:user_id] = nil
      @user = GuestUser
    end

    # Store flash message to session
    def flash(message)

    end


    def breadcrumb_match?(controller: nil, action: nil)
      (controller ? (@route[:options][:controller] ? @route[:options][:controller] == controller : @params[:controller] == controller) : true) &&
      (action ? (@route[:options][:action] ? @route[:options][:action] == action : @params[:action] == action) : true)
    end


    def csrf_token
      session[:csrf_token] ||= SecureRandom.base64(12)
    end

    def check_csrf_token
      obtained_token = @request.post? ? @request.POST['csrf_token'] : @request.GET['csrf_token']
      raise Alfa::Exceptions::Route403, 'CSRF token fail' unless obtained_token == csrf_token
      true
    end
  end


  # Wrapper class for snippets and actions
  class Wrapper
    include Alfa::WrapperMethods

    attr_reader :application, :request, :app_sym, :c_sym, :resourcer, :params

    def initialize(application: nil, request: nil, app_sym: nil, c_sym: nil, resourcer: nil, params: nil, route: nil, caller: nil)
      if caller
        @application = caller.application
        @request = caller.request
        @app_sym = caller.app_sym
        @c_sym = caller.c_sym
        @resourcer = caller.resourcer
        @params = caller.params
        @route = caller.route
      else
        @application = application
        @request = request
        @app_sym = app_sym
        @c_sym = c_sym
        @resourcer = resourcer
        @params = params
        @route = route
      end
    end
  end
end