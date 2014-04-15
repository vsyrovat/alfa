require 'alfa/support'
require 'alfa/exceptions'

module Alfa
  class Controller
    attr_accessor :application, :request, :config, :app_sym, :c_sym

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
      s1 = str.split('@')
      raise Exceptions::E004.new("E004: Bad href argument #{str}: it should contain at most one @ symbol") if s1.length > 2
      res[:app] = s1.last.to_sym if s1.length > 1
      s2 = s1.first.split('#')
      raise Exceptions::E004.new("E004: Bad href argument #{str}: it should contain at most one # symbol") if s2.length > 2
      res[:controller] = s2.first.to_sym if s2.length > 1
      res[:action] = s2.last.to_sym if s2.length > 0
      res
    end


    def session
      @request.session
    end

    # Return current user
    def user
      @user ||= (
        if @request.session[:user_id] && (u = @application.config[:db][:main][:instance][:users].first(id: @request.session[:user_id]))
          User.new(u)
        else
          GuestUser.new
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


    def try_login(username, password)
      u = @application.config[:db][:main][:instance][:users].first(login: username)
      raise "No such login: #{username}" unless u
      if u[:passhash] == Digest::MD5.hexdigest("#{u[:salt]}#{password}")
        # success
        session[:user_id] = u[:id]
        return true
      else
        # fail
        session[:user_id] = nil
        raise 'login fail'
        return false
      end
    end


    def try_register(username, password)
      @config[:db][:main][:instance].transaction do
        unless @config[:db][:main][:instance][:users].first(:login=>username)
          @logger.portion do |l|
            salt = SecureRandom.hex(5)
            passhash = Digest::MD5.hexdigest("#{salt}#{password}")
            @config[:db][:main][:instance][:users].insert(:login=>username, :salt=>salt, :passhash=>passhash)
            l.info("create new user login=#{username}, password=#{password}, salt=#{salt}, passhash=#{passhash}")
          end
          return true, "Registration done"
        end
        return false, "User with login #{username} already exists"
      end
    end

    # Store flash message to session
    def flash(message)

    end
  end
end
