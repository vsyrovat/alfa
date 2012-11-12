require 'test/unit'
require 'alfa/router'

class AlfaRouterTest < Test::Unit::TestCase
  def test_route_match
    # string rules, positive cases
    assert_equal([true, {}], Alfa::Router.route_match?('/', '/'))
    assert_equal([true, {action: 'foo'}], Alfa::Router.route_match?('/:action', '/foo'))
    assert_equal([true, {action: 'foo'}], Alfa::Router.route_match?('/:action/', '/foo/'))
    assert_equal([true, {controller: 'foo', action: 'bar'}], Alfa::Router.route_match?('/:controller/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/foo/bar', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/*/bar', '/foo/bar'))
    assert_equal([true, {action: 'bar'}], Alfa::Router.route_match?('/*/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/**', '/foo/bar'))
    assert_equal([true, {controller: 'foo'}], Alfa::Router.route_match?('/:controller/**', '/foo/bar/baz'))
    assert_equal([true, {path: 'js/jquery/jquery-latest.js', type: :asset}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/jquery-latest.js'))

    # string rules, negative cases
    assert_equal([false, {action: 'foo'}], Alfa::Router.route_match?('/:action', '/foo/'))
    assert_equal([false, {action: 'foo'}], Alfa::Router.route_match?('/:action/', '/foo'))
    assert_equal([false, {}], Alfa::Router.route_match?('/foo/bar/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*', '/foo/bar/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/**/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/**', '/foo/bar/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/non-exists-file.js'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery'))

    # regexp rules, positive cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([true, {controller: 'default', action: 'index'}], Alfa::Router.route_match?(rule, '/default/index'))

    # regexp rules, negative cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([false, {}], Alfa::Router.route_match?(rule, '/'))
  end


  def test_app_match
    # positive cases
    assert_equal(true, Alfa::Router.app_match?('/foo/', '/foo/'))
    assert_equal(true, Alfa::Router.app_match?('/foo', '/foo/'))
    assert_equal(true, Alfa::Router.app_match?('/foo/', '/foo/bar'))
    assert_equal(true, Alfa::Router.app_match?('/foo/bar/', '/foo/bar/'))

    # negative cases
    assert_equal(false, Alfa::Router.app_match?('/foo/', '/bar/'))
    assert_equal(false, Alfa::Router.app_match?('/foo', '/bar/'))
    assert_equal(false, Alfa::Router.app_match?('/foo/', '/bar/bar'))
    assert_equal(false, Alfa::Router.app_match?('/foo/bar/', '/bar/bar'))
  end


  def test_mount
    Alfa::Router.reset
    Alfa::Router.set_paths
    Alfa::Router.draw do
      mount '/admin/', :admin
      mount '/', :frontend
    end
    Alfa::Router.context :app => :admin do
      Alfa::Router.draw do
        route '/', :controller => :main, :action => :index, :layout => :admin
        route '/:controller', :action => :index
      end
    end
    Alfa::Router.context :app => :frontend do
      Alfa::Router.draw do
        route '/', :controller => :main, :action => :index, :layout => :index
        route '/:action', :controller => :main, :layout => :internal
        route '/:controller/:action', :layout => :internal
        route '/:controller/:action/:id', :layout => :internal
      end
    end
    #puts Alfa::Router.instance_variable_get(:@routes)
    assert_equal([{rule: '/', options: {app: :frontend, controller: :main, action: :index, layout: :index}}, {}], Alfa::Router.find_route('/'))
    assert_equal([{rule: '/:action', options: {app: :frontend, controller: :main, layout: :internal}}, {action: 'foo'}], Alfa::Router.find_route('/foo'))
    assert_equal([{rule: '/:controller/:action', options: {app: :frontend, layout: :internal}}, {controller: 'foo', action: 'bar'}], Alfa::Router.find_route('/foo/bar'))
    assert_equal([{rule: '/:controller/:action/:id', options: {app: :frontend, layout: :internal}}, {controller: 'foo', action: 'bar', id: '8'}], Alfa::Router.find_route('/foo/bar/8'))
    assert_equal([{rule: '/', options: {app: :admin, controller: :main, action: :index, layout: :admin}}, {}], Alfa::Router.find_route('/admin/'))
    assert_equal([{rule: '/:controller', options: {app: :admin, action: :index}}, {controller: 'foo'}], Alfa::Router.find_route('/admin/foo'))
    assert_raise Alfa::RouteException404 do
      Alfa::Router.find_route('/admin/foo/bar')
    end
    #assert_equal([{rule: '/:controller/:action/:id', options: {app: :backend, layout: :internal}}, {controller: 'foo', action: 'bar', id: '8'}], Alfa::Router.find_route('/foo/bar/8'))

  end


  # this test loads routes.rb files from data/test_router directory due to emulate real project skeletron
  def test_load_from_files
    Alfa::Router.reset
    Alfa::Router.set_paths :config_path => File.expand_path('../data/test_router/config', __FILE__), :apps_path => File.expand_path('../data/test_router/apps', __FILE__)
    Alfa::Router.load
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
    assert_equal([{rule: '/', options: {app: :frontend, controller: :main, action: :index, layout: :index}}, {}], Alfa::Router.find_route('/'))
    assert_equal([{rule: '/:action', options: {app: :frontend, controller: :main, layout: :internal}}, {action: 'foo'}], Alfa::Router.find_route('/foo'))
    assert_equal([{rule: '/:controller/:action', options: {app: :frontend, layout: :internal}}, {controller: 'foo', action: 'bar'}], Alfa::Router.find_route('/foo/bar'))
    assert_equal([{rule: '/:controller/:action/:id', options: {app: :frontend, layout: :internal}}, {controller: 'foo', action: 'bar', id: '8'}], Alfa::Router.find_route('/foo/bar/8'))
    assert_equal([{rule: '/', options: {app: :backend, controller: :main, action: :index, layout: :admin}}, {}], Alfa::Router.find_route('/admin/'))
    assert_equal([{rule: '/:controller', options: {app: :backend, action: :index}}, {controller: 'foo'}], Alfa::Router.find_route('/admin/foo'))
    assert_raise Alfa::RouteException404 do
      Alfa::Router.find_route('/admin/foo/bar')
    end
  end

end