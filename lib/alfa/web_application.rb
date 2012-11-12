# coding: utf-8
require 'alfa/support'
require 'alfa/exceptions'
require 'alfa/application'
require 'alfa/controller'
require 'alfa/query_logger'
require 'alfa/router'
require 'alfa/tfile'
require 'ruty'
require 'ruty/tags/resources'

Encoding.default_external='utf-8'
Encoding.default_internal='utf-8'

module Alfa
  class WebApplication < Alfa::Application
    private_class_method :new

    @namespaces_stack = []

    def self.inherited subclass
      instance_variables.each do |var|
        subclass.instance_variable_set(var, instance_variable_get(var))
      end
    end

    def self.init!
      self.routes.set_paths :config_path => File.join(PROJECT_ROOT, 'config'), :apps_path => File.join(PROJECT_ROOT, 'apps')
      self.routes.load
      #require File.join(PROJECT_ROOT, 'apps/controllers/application')
      #super
      @inited = true
    end

    # main rack routine
    def self.call env
      @env = env
      headers = {"Content-Type" => 'text/html; charset=utf-8'}
      t_sym = :default
      begin
        self.init! unless @inited
        response_code = 200
        route, params = self.routes.find_route @env['PATH_INFO']
        app_sym = route[:options].has_key?(:app) ? route[:options][:app] : params[:app]
        c_sym = route[:options].has_key?(:controller) ? route[:options][:controller] : params[:controller]
        a_sym = route[:options].has_key?(:action) ? route[:options][:action] : params[:action]
        l_sym = route[:options].has_key?(:layout) ? route[:options][:layout] : :default
        t_sym = route[:options].has_key?(:type) ? route[:options][:type] : :default
        if t_sym == :asset
          body = File.read(File.expand_path('../../../assets/' + params[:path], __FILE__))
          case File.extname(params[:path]).downcase
            when '.js'
              headers = {'Content-Type' => 'application/javascript; charset=utf-8'}
            when '.css'
              headers = {'Content-Type' => 'text/css; charset=utf-8'}
            else
          end
        else
          controller = self.invoke_controller(app_sym, c_sym)
          raise Alfa::RouteException404 unless controller.public_methods.include?(a_sym)
          controller.__send__(a_sym)
          data = controller._instance_variables_hash
          Ruty::Tags::RequireStyle.clean_cache
          content = self.render_template(File.join(c_sym.to_s, a_sym.to_s + '.tpl'), data)
          body = self.render_layout(l_sym.to_s + '.tpl', {body: content})
          headers = {"Content-Type" => 'text/html; charset=utf-8'}
        end
      rescue Alfa::RouteException404
        response_code = 404
        body = 'Url not found<br>urls map:<br>'
        body += self.routes.instance_variable_get(:@routes).inspect
      rescue Exception => e
        response_code = 500
        body = "Error occured: #{e.message} at #{e.backtrace.first}"
      end
      if t_sym == :default
        debug_info = '<hr>Queries:<br>' + Alfa::QueryLogger.logs.map { |log|
          r = "#{log[:num]}: #{log[:query]} | #{log[:status]}"
          r += ", error: #{log[:error]}" if log[:status] == :fail
          r += ", logger hash: #{log[:logger_hash]}"
          r
        }.join('<br>')
        debug_info += "<hr>rack input: #{env['rack.session']}"
      end
      [response_code, headers, [body, debug_info]]
    end

    # router
    def self.routes
      @router ||= Alfa::Router
    end


  # private section

    def self.invoke_controller application, controller
      @controllers ||= {}
      require File.join(PROJECT_ROOT, 'apps', application.to_s, 'controllers', controller.to_s)
      @controllers[[application, controller]] ||= Kernel.const_get(Alfa::Support.capitalize_name(controller)+'Controller').new
      @controllers[[application, controller]]
    end

    def self.render_template template, data = {}
      t = self.loader.get_template File.join('views', template)
      t.render data
    end

    def self.render_layout layout, data = {}
      t = self.loader.get_template File.join('layouts', layout)
      t.render data
    end

    def self.loader
      @loader ||= Ruty::Loaders::Filesystem.new(:dirname => File.join(PROJECT_ROOT, 'app'))
    end

  end
end