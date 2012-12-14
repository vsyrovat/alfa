# coding: utf-8
require 'alfa/support'
require 'alfa/exceptions'
require 'alfa/application'
require 'alfa/tfile'
require 'alfa/controller'
require 'alfa/router'
require 'ruty'
require 'ruty/bugfix'
require 'ruty/upgrade'
require 'ruty/tags/resources'

Encoding.default_external='utf-8'
Encoding.default_internal='utf-8'

module Alfa
  class WebApplication < Alfa::Application

    @namespaces_stack = []
    @bputs = []

    def self.inherited subclass
      instance_variables.each do |var|
        subclass.instance_variable_set(var, instance_variable_get(var))
      end
    end

    def self.init!
      self.routes.set_paths :config_path => File.join(PROJECT_ROOT, 'config'), :apps_path => File.join(PROJECT_ROOT, 'apps')
      self.routes.load
      super
    end

    # main rack routine
    def self.call env
      @env = env
      @bputs = []
      headers = {"Content-Type" => 'text/html; charset=utf-8'}
      t_sym = :default
      begin
        @logger << "#{env['REQUEST_METHOD']} #{env['REQUEST_URI']} #{env['SERVER_PROTOCOL']} from #{env['REMOTE_ADDR']} at #{DateTime.now}, processing by pid #{$$}\n"
        @logger << "  HTTP_HOST:            #{env['HTTP_HOST']}\n"
        @logger << "  HTTP_ACCEPT:          #{env['HTTP_ACCEPT']}\n"
        @logger << "  HTTP_ACCEPT_LANGUAGE: #{env['HTTP_ACCEPT_LANGUAGE']}\n"
        @logger << "  PATH_INFO:            #{env['PATH_INFO']}\n"
        response_code = 200
        route, params = self.routes.find_route @env['PATH_INFO']
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
          app_sym = route[:options].has_key?(:app) ? route[:options][:app] : params[:app]
          c_sym = route[:options].has_key?(:controller) ? route[:options][:controller] : params[:controller]
          a_sym = route[:options].has_key?(:action) ? route[:options][:action] : params[:action]
          l_sym = route[:options].has_key?(:layout) ? route[:options][:layout] : :default
          controller = self.invoke_controller(app_sym, c_sym)
          raise Alfa::RouteException404 unless controller.public_methods.include?(a_sym)
          controller.__send__(a_sym)
          data = controller._instance_variables_hash
          Ruty::Tags::RequireStyle.clean_cache
          content = self.render_template(app_sym.to_s, File.join(c_sym.to_s, a_sym.to_s + '.tpl'), data)
          body = self.render_layout(app_sym.to_s, l_sym.to_s + '.tpl', {body: content})
          headers = {"Content-Type" => 'text/html; charset=utf-8'}
        end
      rescue Alfa::RouteException404 => e
        response_code = 404
        body = 'Url not found<br>urls map:<br>'
        body += self.routes.instance_variable_get(:@routes).inspect
        @logger << "404: Url not found (#{e.message})\n"
      rescue Exception => e
        response_code = 500
        body = "Error occured: #{e.message} at #{e.backtrace.first}<br>Full backtrace:<br>#{e.backtrace.join("<br>")}"
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
      @logger << "\n"
      @log_file.flush
      return [response_code, headers, [body, @bputs.join('<br>')]]
    end

    # router
    def self.routes
      @router ||= Alfa::Router
    end


    def self.bputs arg
      @bputs << "#{arg}\n"
    end


  # private section

    def self.invoke_controller application, controller
      @controllers ||= {}
      require File.join(PROJECT_ROOT, 'apps', application.to_s, 'controllers', controller.to_s)
      @controllers[[application, controller]] ||= Kernel.const_get(Alfa::Support.capitalize_name(controller)+'Controller').new
    end

    def self.render_template app, template, data = {}
      t = self.loader.get_template File.join(app, 'templates', template)
      t.render data
    end

    def self.render_layout app, layout, data = {}
      t = self.loader.get_template File.join(app, 'layouts', layout)
      t.render data
    end

    def self.loader
      @loader ||= Ruty::Loaders::Filesystem.new(:dirname => File.join(PROJECT_ROOT, 'apps'))
    end

  end
end

def bputs arg
  Alfa::WebApplication.bputs arg
end
