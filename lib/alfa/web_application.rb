require 'alfa/support'
require 'alfa/exceptions'
require 'alfa/application'
require 'alfa/tfile'
require 'alfa/controller'
require 'alfa/router'
require 'alfa/ruty'
require 'alfa/snippeter'
require 'alfa/wrapper'
require 'alfa/resourcer'
require 'rack/utils'
require 'rack/request'
require 'rack/file_alfa'
require 'haml'
require 'alfa/template-inheritance'
require 'tilt/alfa_patch'
require 'haml/alfa_patch'
require 'json'

module Alfa
  class WebApplication < Alfa::Application

    @bputs = []
    @haml_templates = {}

    class << self
      attr_reader :request
    end

    def self.inherited(subclass)
      instance_variables.each do |var|
        subclass.instance_variable_set(var, instance_variable_get(var))
      end
    end

    # noinspection RubyResolve
    def self.init!
      super
      Alfa::Router.reset
      Alfa::Router.apps_dir = File.join(@config[:project_root], 'apps')
      load File.join(@config[:project_root], 'config/routes.rb')
      TemplateInheritance.logger = @logger
      Alfa.GROUPS = @config[:groups]
      Alfa::Snippeter.config = @config
      Alfa::Snippeter.mounts = Alfa::Router.mounts
      Alfa::Snippeter.load
    end

    # main Rack routine
    def self.call(env, &block)
      start_time = Time.now
      response_code = nil # required for store context inside @logger.portion
      headers = {} # required for store context inside @logger.portion
      body = nil # required for store context inside @logger.portion
      @logger.portion(:sync=>true) do |l|
        @config[:db].each_value { |db| db[:instance].loggers = [l] }
        TemplateInheritance.logger = l
        @bputs = []
        headers = {"Content-Type" => 'text/html; charset=utf-8'}
        t_sym = :default
        begin
          l.info "#{env['REQUEST_METHOD']} #{env['REQUEST_URI']} #{env['SERVER_PROTOCOL']} from #{env['REMOTE_ADDR']} at #{DateTime.now}"
          # l.info "  HTTP_HOST: #{env['HTTP_HOST']}"
          # l.info "  HTTP_ACCEPT: #{env['HTTP_ACCEPT']}"
          # l.info "  HTTP_ACCEPT_LANGUAGE: #{env['HTTP_ACCEPT_LANGUAGE']}"
          # l.info "  PATH_INFO: #{env['PATH_INFO']}"
          response_code = 200
          route, params = self.routes.find_route(Rack::Utils.unescape(env['PATH_INFO']))
          t_sym = route[:options].has_key?(:type) ? route[:options][:type] : :default
          if t_sym == :asset
            realpath = File.expand_path('../../../assets/' + params[:path], __FILE__)
            body = File.read(realpath)
            case File.extname(params[:path]).downcase
              when '.js'
                headers['Content-Type'] = 'application/javascript; charset=utf-8'
              when '.css'
                headers['Content-Type'] = 'text/css; charset=utf-8'
              else
            end
            headers['Last-Modified'] = File.mtime(realpath).httpdate
            headers['Cache-Control'] = 'max-age=2592000'
            headers['Expires'] = (Time.now + 2592000).httpdate
          else
            request = Rack::Request.new(env) # weakref?
            app_sym, c_sym, a_sym, l_sym = route_to_symbols(route, params)
            controller = self.invoke_controller(app_sym, c_sym)
            unless controller.class.instance_methods(false).include?(a_sym)
              if route[:rule] =~ /^\/:(controller|action)\/?$/
                route, params = self.routes.find_route(Rack::Utils.unescape(env['PATH_INFO']), exclude: [route[:rule]])
                app_sym, c_sym, a_sym, l_sym = route_to_symbols(route, params)
                controller = self.invoke_controller(app_sym, c_sym)
                raise Exceptions::Route404 unless controller
              end
            end
            raise Exceptions::Route404 unless controller.class.instance_methods(false).include?(a_sym)
            controller._clear_instance_variables # cleanup
            controller.application = self
            controller.request = request
            controller.app_sym = app_sym
            controller.c_sym = c_sym
            data = controller.__send__(a_sym)
            case controller.class.get_content_type(a_sym)
              when :json
                headers['Content-Type'] = 'application/json; charset=utf-8'
                body = JSON.generate(data, quirks_mode: true)
              else
                data = controller._instance_variables_hash
                resourcer = Alfa::Resourcer.new
                wrapper = Alfa::Wrapper.new(application: self, request: request, app_sym: app_sym, c_sym: c_sym, resourcer: resourcer)
                Ruty::Tags::RequireStyle.clean_cache # cleanup
                Ruty::Tags::RequireScript.clean_cache # cleanup
                content = self.render_template(app_sym, c_sym, a_sym, controller, wrapper, data, &block)
                if controller.class.get_render(a_sym) == :partial
                  body = content
                else
                  body = self.render_layout(app_sym.to_s, l_sym.to_s, controller, wrapper, data.merge({:@body => content}))
                end
                headers["Content-Type"] = 'text/html; charset=utf-8'
            end
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
          l.error "ERROR: #{e.message} at #{e.backtrace.first}"
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


    def self.route_to_symbols(route, params)
      app_sym = route[:options].has_key?(:app) ? route[:options][:app] : params[:app]
      c_sym = route[:options].has_key?(:controller) ? route[:options][:controller] : params[:controller]
      a_sym = route[:options].has_key?(:action) ? route[:options][:action] : params[:action]
      l_sym = route[:options].has_key?(:layout) ? route[:options][:layout] : :default
      return app_sym, c_sym, a_sym, l_sym
    end

    # router
    def self.routes
      @router ||= Alfa::Router
    end


    def self.snippets
      @snippeter ||= Alfa::Snippeter
    end

    # Evaluate snippet with given name
    # @param Symbol name
    # @param Alfa::Controller controller
    # return String
    def self.snippet(name, wrapper)
      block = snippets[wrapper.app_sym][name]
      raise "Not found snippet #{name} for app #{wrapper.app_sym}" unless block
      wrapper.instance_eval(&block)
      data = wrapper._instance_variables_hash
      render_snippet(wrapper.app_sym, name, wrapper, data)
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


    def self.redirect(url, code=302)
      raise Exceptions::HttpRedirect.new(url, code)
    end


  # private section

    def self.verify_config
      super
      raise Exceptions::E002.new('config[:document_root] should be defined') unless @config[:document_root]
      raise Exceptions::E002.new('config[:templates_priority] should be defined') unless @config[:templates_priority]
      raise Exceptions::E001.new('config[:groups] should be a hash') unless @config[:groups].is_a?(::Hash)
      @config[:groups][:public] = [] unless @config[:groups][:public]
    end

    def self.invoke_controller(a_sym, c_sym)
      f = File.join(@config[:project_root], 'apps', a_sym.to_s, 'controllers', c_sym.to_s + '.rb')
      return nil unless File.exists?(f)
      load f
      klass_name = Alfa::Support.camelcase_name(c_sym)+'Controller'
      klass = Kernel.const_get(klass_name) # weakref?
      instance = klass.new
      Object.module_eval{remove_const(klass_name)}
      return instance
    end

    def self.render_template(app_sym, c_sym, a_sym, controller, wrapper, data = {}, &block)
      wrapper.resourcer.level = :action
      render(file: File.join(@config[:project_root], 'apps', app_sym.to_s, 'templates', c_sym.to_s, a_sym.to_s), controller: controller, data: data, wrapper: wrapper, &block)
    end

    def self.render_layout(app, layout, controller, wrapper, data = {})
      wrapper.resourcer.level = :layout
      render(file: File.join(@config[:project_root], 'apps', app, 'layouts', layout.to_s), controller: controller, wrapper: wrapper, data: data)
    end

    def self.render_snippet(app_sym, snip_sym, wrapper, data = {})
      wrapper.resourcer.level = :snippet
      render(file: File.join(@config[:project_root], 'apps', app_sym.to_s, 'templates/_snippets', snip_sym.to_s), wrapper: wrapper, data: data)
    end

    def self.render(file: nil, controller: nil, wrapper: nil, data: {})
      @config[:templates_priority].each do |ext|
        f = "#{file}.#{ext}"
        if File.exist?(f)
          case ext
            when :haml
              template = self.haml_template(f, controller, wrapper)
              yield(controller, template) if block_given? # required only for thread isolation test
              return template.render data
            when :tpl
              Ruty::AUX_VARS[:controller] = controller
              template = self.ruty_loader.get_template(f)
              return template.render data
            else
              raise StandardError.new("Unknown template type: #{ext}")
          end
          break
        end
      end
      raise StandardError.new("Can't find template #{file}.[#{@config[:templates_priority].join('|')}]")
    end

    def self.ruty_loader
      @ruty_loader ||= Ruty::Loaders::Filesystem.new(:dirname => File.join(@config[:project_root], 'apps'))
    end

    def self.haml_template(file, controller, wrapper)
      # @haml_templates[file.to_sym] ||= TemplateInheritance::Template.new(file)
      scope = TemplateInheritance::RenderScope.new(controller, wrapper, wrapper.resourcer)
      TemplateInheritance::Template.new(file, scope)
    end

  end
end

def bputs arg
  Alfa::WebApplication.bputs arg
end
