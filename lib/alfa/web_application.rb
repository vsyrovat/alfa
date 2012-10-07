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
      require File.join(PROJECT_ROOT, 'app/routes')
      require File.join(PROJECT_ROOT, 'app/controllers/application')
      super
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
        route, params = self.find_route
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
          controller = self.invoke_controller(c_sym)
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
        body = 'Url not found'
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

    # set routes
    def self.routes &block
      @routes = []
      @routes << {:rule => '/~assets/**', :options => {type: :asset}}
      class_eval &block
    end


    def self.mount root, options = {}

    end

    def self.route rule, options = {}
      @routes << {:rule => rule, :options => options.merge({:namespace => @namespaces_stack.dup})}
    end

  private

    def self.find_route
      url = @env['PATH_INFO']
      @routes.each do |route|
        is_success, params = self.route_match? route[:rule], url
        return route, params if is_success
      end
      raise Alfa::RouteException404
    end

    def self.route_match? rule, url
      if rule.is_a? String
        rule_trail_slash = rule[-1] == '/'
        url_trail_slash = url[-1] == '/'
        rule_segments = rule.split('/').reject(&:empty?)
        url_segments = url.split('/').reject(&:empty?)
        if url_segments.first == '~assets'
          path = url_segments[1..-1].join('/')
          if File.file?(File.expand_path('../../../assets/'+path, __FILE__))
            return true, {path: path, type: :asset}
          else
            return false, {}
          end
        end
        rule_segments += [nil]*(url_segments.size - rule_segments.size) if url_segments.size > rule_segments.size
        pares = {}
        skip_flag = false
        fail_flag = false
        rule_segments.zip(url_segments).each do |rule_segment, url_segment|
          skip_flag = true if rule_segment == '**'
          if rule_segment =~ /^:[a-z]+\w*$/i && url_segment =~ /^[a-z0-9_]+$/
            pares[rule_segment[1..-1].to_sym] = url_segment
          elsif (rule_segment == url_segment) || (rule_segment == '*' && url_segment =~ /^[a-z0-9_]+$/) || (rule_segment == nil && skip_flag) || rule_segment == '**'
          else
            fail_flag = true
            break
          end
        end
        fail_flag = true if rule_trail_slash != url_trail_slash
        return !fail_flag, pares
      elsif rule.is_a? Regexp
        match = rule.match url
        if match
          pares = Hash[match.names.map(&:to_sym).zip(match.captures)]
          return true, pares
        else
          return false, {}
        end
      end
    end

    def self.invoke_controller controller
      @controllers ||= {}
      controller = controller.to_s
      require File.join(PROJECT_ROOT, 'app/controllers', controller.to_s)
      @controllers[controller] ||= Kernel.const_get(Alfa::Support.capitalize_name(controller)+'Controller').new
      @controllers[controller]
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