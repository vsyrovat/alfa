module Alfa
  class Router

    # initialize class variables
    @routes = []
    @cursor = @routes
    @cursors_stack = []
    @mounts = []
    @default_paths = {:apps_path => nil, :config_path => nil}

    def self.call &block
    end


    def self.set_paths options = {}
      @paths = @default_paths.merge(options)
    end


    def self.context options = {}, &block
      new_routes_container = []
      new_cursor = new_routes_container
      if options.has_key?(:app)
        options[:app] = @mounts.find {|item| item[:app] == options[:app]}
      end
      @cursor << {:context => options, :routes => new_routes_container}
      @cursors_stack.push @cursor
      @cursor = new_cursor
      yield
      @cursor = @cursors_stack.pop
    end


    def self.reset
      @routes = []
      @cursor = @routes
      @cursors_stack = []
      @mounts = []
    end


    def self.load
      Kernel.load File.join(@paths[:config_path], 'routes.rb')
    end


    def self.reload
      self.reset
      self.load
    end

    # Set routes
    # Example:
    #   WebApplication.Router.draw do
    #     mount '/admin/', :admin
    #     route '/rss.xml', 'frontend/feeds#rss'
    #     route '/atom.xml', 'frontend/feeds#atom'
    #     mount '/', :frontend
    #     subdomain :forum do
    #       mount '/', :forum
    #     end
    #   end
    def self.draw &block
      class_eval &block
      route '/~assets/:path**', type: :asset if @cursors_stack.empty?
    end

    # Set rules in subdomain context
    def self.subdomain &block
    end

    # Mount application to path
    # Examples:
    # all requests to url site.com/admin/ and nested (site.com/admin/*) will be sent to application 'backend' (/apps/backend)
    #   mount '/admin/', :admin
    # all requests to site.com/ and nested (site.com/*) will be sent to application 'frontend' (/apps/frontend)
    #   mount '/', :frontend
    def self.mount path, app, options = {}
      @mounts << {:path => path, :app => app, :options => options}
      if @paths[:apps_path]
        self.context :app => app do
          Kernel.load File.join(@paths[:apps_path], app.to_s, 'routes.rb')
        end
      end
    end

    # Sets route rule
    def self.route rule, options = {}
      @cursor << {:rule => rule, :options => options}
      #puts "set rule '#{rule}', routes = #{@routes}"
    end


    def self.app_match? path, url
      path_segments = path.split('/').reject(&:empty?)
      url_segments = url.split('/').reject(&:empty?)
      path_segments.zip(url_segments).reduce(true) {|res, pare| res && pare[0] == pare[1]}
    end


    def self.route_match? rule, url
      if rule.is_a? String
        rule_trail_slash = rule[-1] == '/'
        url_trail_slash = url[-1] == '/'
        rule_segments = rule.split('/').reject(&:empty?) # @todo optimize (one split per server session instead of split per method call)
        url_segments = url.split('/').reject(&:empty?)   # @todo optimize (one split per server session instead of split per method call)
        if rule_segments.first == '~assets' && url_segments.first == '~assets'
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

    # @param string url
    # @return route, params
    # route is route that given in routes.rb
    # params is detected params
    def self.find_route url
      #url = @env['PATH_INFO']
      @routes.each do |route|
        if route[:context].is_a? Hash # container
          if self.app_match?(route[:context][:app][:path], url)
            url = url[(route[:context][:app][:path].length-1)..-1]
            route[:routes].each do |r|
              is_success, params = self.route_match?(r[:rule], url)
              r[:options][:app] = route[:context][:app][:app]
              return r, params if is_success
            end
            raise Alfa::RouteException404
          end
          # else - ???
        else
          is_success, params = self.route_match?(route[:rule], url)
          #puts route[:context]
          #puts "route: #{route}, url: #{url}, is_success: #{is_success}"
          return route, params if is_success
        end
      end
      raise Alfa::RouteException404
    end

  end
end