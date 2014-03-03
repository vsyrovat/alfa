require 'alfa/support'
require 'alfa/exceptions'
require 'alfa/application'
require 'alfa/tfile'
require 'alfa/controller'
require 'alfa/router'
require 'alfa/ruty'
require 'alfa/user'
require 'rack/utils'
require 'rack/request'
require 'rack/file_alfa'
require 'digest/md5'
require 'securerandom'

module Alfa
  class WebApplication < Alfa::Application

    @bputs = []
    @controllers = {}

    class << self
      attr_reader :request
    end

    def self.inherited subclass
      instance_variables.each do |var|
        subclass.instance_variable_set(var, instance_variable_get(var))
      end
    end

    def self.init!
      super
      Alfa::Router.reset
      Alfa::Router.apps_dir = File.join(@config[:project_root], 'apps')
      load File.join(@config[:project_root], 'config/routes.rb')
      @controllers.clear
    end

    # main rack routine
    def self.call(env)
      start_time = Time.now
      response_code = nil # required for store context inside @logger.portion
      headers = {} # required for store context inside @logger.portion
      body = nil # required for store context inside @logger.portion
      @logger.portion(:sync=>true) do |l|
        @config[:db].each_value { |db| db[:instance].loggers = [l] }
        @env = env
        @bputs = []
        headers = {"Content-Type" => 'text/html; charset=utf-8'}
        t_sym = :default
        begin
          l.info "#{env['REQUEST_METHOD']} #{env['REQUEST_URI']} #{env['SERVER_PROTOCOL']} from #{env['REMOTE_ADDR']} at #{DateTime.now}"
          #l.info "  HTTP_HOST: #{env['HTTP_HOST']}"
          #@logger.info "  HTTP_ACCEPT: #{env['HTTP_ACCEPT']}"
          #@logger.info "  HTTP_ACCEPT_LANGUAGE: #{env['HTTP_ACCEPT_LANGUAGE']}"
          #@logger.info "  PATH_INFO: #{env['PATH_INFO']}"
          response_code = 200
          route, params = self.routes.find_route(Rack::Utils.unescape(@env['PATH_INFO']))
          t_sym = route[:options].has_key?(:type) ? route[:options][:type] : :default
          if t_sym == :asset
            body = File.read(File.expand_path('../../../assets/' + params[:path], __FILE__))
            case File.extname(params[:path]).downcase
              when '.js'
                headers['Content-Type'] = 'application/javascript; charset=utf-8'
              when '.css'
                headers['Content-Type'] = 'text/css; charset=utf-8'
              else
            end
          else
            @request = Rack::Request.new(env) # weakref?
            app_sym = route[:options].has_key?(:app) ? route[:options][:app] : params[:app]
            c_sym = route[:options].has_key?(:controller) ? route[:options][:controller] : params[:controller]
            a_sym = route[:options].has_key?(:action) ? route[:options][:action] : params[:action]
            l_sym = route[:options].has_key?(:layout) ? route[:options][:layout] : :default
            controller = self.invoke_controller(app_sym, c_sym)
            raise Exceptions::Route404 unless controller.class.instance_methods(false).include?(a_sym)
            controller._clear_instance_variables # cleanup
            controller.application = self
            controller.app_sym = app_sym
            controller.c_sym = c_sym
            controller.__send__(a_sym)
            data = controller._instance_variables_hash
            Ruty::Tags::RequireStyle.clean_cache # cleanup
            Ruty::Tags::RequireScript.clean_cache # cleanup
            content = self.render_template(app_sym, c_sym, a_sym, controller, data)
            body = self.render_layout(app_sym.to_s, l_sym.to_s + '.tpl', {body: content})
            headers["Content-Type"] = 'text/html; charset=utf-8'
          end
        rescue Alfa::Exceptions::Route404 => e
          response_code = 404
          body = 'Url not found<br>urls map:<br>'
          body += self.routes.instance_variable_get(:@routes).inspect
          l.info "404: Url not found (#{e.message})"
        rescue Exceptions::HttpRedirect => e
          response_code = e.code
          headers['Location'] = e.url.to_s
          body = ''
        rescue Exception => e
          response_code = 500
          body = "Error occured: #{e.message} at #{e.backtrace.first}<br>Full backtrace:<br>\n#{e.backtrace.join("<br>\n")}"
        end
        if t_sym == :default
          #debug_info = '<hr>Queries:<br>' + @logger.logs.map { |log|
          #  r = "#{log[:num]}: #{log[:query]} | #{log[:status]}"
          #  r += ", error: #{log[:error]}" if log[:status] == :fail
          #  r += ", logger hash: #{log[:logger_hash]}"
          #  r
          #}.join('<br>')
          debug_info = "<hr>rack env: #{env.inspect}"
        end
        l.info "RESPONSE: #{response_code} (#{sprintf('%.4f', Time.now - start_time)} sec)"
        l << "\n"
      end
      return [response_code, headers, [body, @bputs.join('<br>')]]
    end

    # router
    def self.routes
      @router ||= Alfa::Router
    end


    def self.rackup(builder)
      builder.use Rack::Session::Cookie
      if @config[:serve_static]
        builder.run Rack::Cascade.new([
          Rack::FileAlfa.new(@config[:document_root]),
          self,
        ])
      else
        builder.run self
      end
    end


    def self.bputs arg
      @bputs << "#{arg}\n"
    end


    def self.session
      @request.session
    end


    def self.user
      return @config[:db][:main][:instance][:users].find(session['user_id']) if session['user_id']
      GuestUser
    end


    def self.try_register(username, password)
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


    def self.try_login(username, password)
      u = @config[:db][:main][:instance][:users].first(:login=>username)
      raise "No such login: #{username}" unless u
      if u[:passhash] == Digest::MD5.hexdigest("#{u[:salt]}#{password}")
        # success
        #@request.session.destroy_session
        return true
      else
        # fail
        raise 'login fail'
        return false
      end
    end


    def self.redirect(url, code=302)
      raise Exceptions::HttpRedirect.new(url, code)
    end

  # private section

    def self.verify_config
      super
      raise Exceptions::E002.new unless @config[:document_root]
    end

    def self.invoke_controller(application, controller)
      return @controllers[[application, controller]] if @controllers[[application, controller]]
      load File.join(@config[:project_root], 'apps', application.to_s, 'controllers', controller.to_s + '.rb')
      klass_name = Alfa::Support.camelcase_name(controller)+'Controller'
      klass = Kernel.const_get(klass_name) # weakref?
      @controllers[[application, controller]] = klass.dup.new # weakref?
      Object.module_eval{remove_const(klass_name)}
      return @controllers[[application, controller]]
    end

    def self.render_template(app_sym, c_sym, a_sym, controller, data = {})
      Ruty::AUX_VARS[:controller] = controller
      t = self.loader.get_template File.join(app_sym.to_s, 'templates', c_sym.to_s, "#{a_sym}.tpl")
      t.render data
    end

    def self.render_layout app, layout, data = {}
      t = self.loader.get_template File.join(app, 'layouts', layout)
      t.render data
    end

    def self.loader
      @loader ||= Ruty::Loaders::Filesystem.new(:dirname => File.join(@config[:project_root], 'apps'))
    end

  end
end

def bputs arg
  Alfa::WebApplication.bputs arg
end
