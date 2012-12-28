require 'test/unit'
require 'alfa/router'

class AlfaRouterTest < Test::Unit::TestCase
  def test_01 # route_match
    # string rules, positive cases
    assert_equal([true, {}], Alfa::Router.route_match?('/', '/'))
    assert_equal([true, {action: :foo}], Alfa::Router.route_match?('/:action', '/foo'))
    assert_equal([true, {action: :foo}], Alfa::Router.route_match?('/:action/', '/foo/'))
    assert_equal([true, {controller: :foo, action: :bar}], Alfa::Router.route_match?('/:controller/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/foo/bar', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/*/bar', '/foo/bar'))
    assert_equal([true, {action: :bar}], Alfa::Router.route_match?('/*/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/**', '/foo/bar'))
    assert_equal([true, {controller: :foo}], Alfa::Router.route_match?('/:controller/**', '/foo/bar/baz'))
    assert_equal([true, {path: 'js/jquery/jquery-latest.js', type: :asset}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/jquery-latest.js'))
    assert_equal([true, {}], Alfa::Router.route_match?('/hello.html', '/hello.html'))

    # string rules, negative cases
    assert_equal([false, {action: :foo}], Alfa::Router.route_match?('/:action', '/foo/'))
    assert_equal([false, {action: :foo}], Alfa::Router.route_match?('/:action/', '/foo'))
    assert_equal([false, {}], Alfa::Router.route_match?('/foo/bar/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*', '/foo/bar/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/**/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/**', '/foo/bar/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/non-exists-file.js'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery'))
    assert_equal([false, {}], Alfa::Router.route_match?('/hello.html', '/~assets/js/jquery/jquery-latest.js'))

    # regexp rules, positive cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([true, {controller: 'default', action: 'index'}], Alfa::Router.route_match?(rule, '/default/index'))

    # regexp rules, negative cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([false, {}], Alfa::Router.route_match?(rule, '/'))
  end


  def test_02 # app_match
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


  def prepare_router
    Alfa::Router.draw do
      route '/hello.html'
      mount '/admin/', :admin
      Alfa::Router.context :app => :admin do
        Alfa::Router.draw do
          route '/', :controller => :main, :action => :index, :layout => :admin
          route '/:controller', :action => :index
        end
      end
      mount '/', :frontend
      Alfa::Router.context :app => :frontend do
        Alfa::Router.draw do
          route '/', :controller => :main, :action => :index, :layout => :index
          route '/:action', :controller => :main, :layout => :internal
          route '/:controller/:action', :layout => :internal
          route '/:controller/:action/:id', :layout => :internal
        end
      end
    end
  end

  # Checks right order of draw and mounted rules
  def test_03 # Router's internal routes struct
    Alfa::Router.reset
    prepare_router
    assert_equal(
        [
            {:rule=>"/~assets/:path**", :options=>{:type=>:asset}},
            {:rule=>"/hello.html", :options=>{}},
            {:context=>{:app=>{:path=>"/admin/", :app=>:admin, :options=>{}}},
             :routes=>[
                 {:rule=>"/", :options=>{:controller=>:main, :action=>:index, :layout=>:admin}},
                 {:rule=>"/:controller", :options=>{:action=>:index}}
             ]},
            {:context=>{:app=>{:path=>"/", :app=>:frontend, :options=>{}}},
             :routes=>[
                 {:rule=>"/", :options=>{:controller=>:main, :action=>:index, :layout=>:index}},
                 {:rule=>"/:action", :options=>{:controller=>:main, :layout=>:internal}},
                 {:rule=>"/:controller/:action", :options=>{:layout=>:internal}},
                 {:rule=>"/:controller/:action/:id", :options=>{:layout=>:internal}},
             ]},
        ],
        Alfa::Router.instance_variable_get(:@routes)
    )
  end


  def test_04 # mount
    Alfa::Router.reset
    prepare_router
    #puts Alfa::Router.instance_variable_get(:@routes)
    assert_equal([{rule: '/hello.html', options: {}}, {}], Alfa::Router.find_route('/hello.html'))
    assert_equal([{rule: '/', options: {app: :frontend, controller: :main, action: :index, layout: :index}}, {}], Alfa::Router.find_route('/'))
    assert_equal([{rule: '/:action', options: {app: :frontend, controller: :main, layout: :internal}}, {action: :foo}], Alfa::Router.find_route('/foo'))
    assert_equal([{rule: '/:controller/:action', options: {app: :frontend, layout: :internal}}, {controller: :foo, action: :bar}], Alfa::Router.find_route('/foo/bar'))
    assert_equal([{rule: '/:controller/:action/:id', options: {app: :frontend, layout: :internal}}, {controller: :foo, action: :bar, id: :'8'}], Alfa::Router.find_route('/foo/bar/8'))
    assert_equal([{rule: '/', options: {app: :admin, controller: :main, action: :index, layout: :admin}}, {}], Alfa::Router.find_route('/admin/'))
    assert_equal([{rule: '/:controller', options: {app: :admin, action: :index}}, {controller: :foo}], Alfa::Router.find_route('/admin/foo'))
    assert_raise Alfa::Exceptions::Route404 do
      Alfa::Router.find_route('/admin/foo/bar')
    end
    assert_equal([{rule: '/~assets/:path**', options: {type: :asset}}, {path: 'js/jquery/jquery-latest.js', type: :asset}], Alfa::Router.find_route('/~assets/js/jquery/jquery-latest.js'))
    #assert_equal([{rule: '/:controller/:action/:id', options: {app: :backend, layout: :internal}}, {controller: 'foo', action: 'bar', id: '8'}], Alfa::Router.find_route('/foo/bar/8'))
  end

  # Checks right order of draw and mounted rules
  def test_05
    Alfa::Router.reset
    Alfa::Router.apps_dir = File.expand_path('../data/test_router/1/apps', __FILE__)
    load File.expand_path('../data/test_router/1/config/routes.rb', __FILE__)
    assert_equal(
        [
            {:rule=>"/~assets/:path**", :options=>{:type=>:asset}},
            {:context=>{:app=>{:path=>"/admin/", :app=>:backend, :options=>{}}},
             :routes=>[
                 {:rule=>"/", :options=>{:controller=>:main, :action=>:index, :layout=>:index}},
                 {:rule=>"/:controller", :options=>{:action=>:index}}
             ]},
            {:context=>{:app=>{:path=>"/", :app=>:frontend, :options=>{}}},
             :routes=>[
                 {:rule=>"/", :options=>{:controller=>:main, :action=>:index, :layout=>:index}},
                 {:rule=>"/:action", :options=>{:controller=>:main, :layout=>:internal}},
                 {:rule=>"/:controller/:action", :options=>{:layout=>:internal}},
                 {:rule=>"/:controller/:action/:id", :options=>{:layout=>:internal}},
             ]},
        ],
        Alfa::Router.instance_variable_get(:@routes)
    )
  end

  # this test loads routes.rb files from data/test_router directory to simulate real project skeletron
  def test_06 # load_from_files
    Alfa::Router.reset
    Alfa::Router.apps_dir = File.expand_path('../data/test_router/1/apps', __FILE__)
    load File.expand_path('../data/test_router/1/config/routes.rb', __FILE__)
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
    assert_equal([{rule: '/', options: {app: :frontend, controller: :main, action: :index, layout: :index}}, {}], Alfa::Router.find_route('/'))
    assert_equal([{rule: '/:action', options: {app: :frontend, controller: :main, layout: :internal}}, {action: :foo}], Alfa::Router.find_route('/foo'))
    assert_equal([{rule: '/:controller/:action', options: {app: :frontend, layout: :internal}}, {controller: :foo, action: :bar}], Alfa::Router.find_route('/foo/bar'))
    assert_equal([{rule: '/:controller/:action/:id', options: {app: :frontend, layout: :internal}}, {controller: :foo, action: :bar, id: :'8'}], Alfa::Router.find_route('/foo/bar/8'))
    assert_equal([{rule: '/', options: {app: :backend, controller: :main, action: :index, layout: :index}}, {}], Alfa::Router.find_route('/admin/'))
    assert_equal([{rule: '/:controller', options: {app: :backend, action: :index}}, {controller: :foo}], Alfa::Router.find_route('/admin/foo'))
  end

  # alternative route format 'url' => 'controller#action'
  def test_07
    Alfa::Router.reset
    Alfa::Router.draw do
      route '/' => 'default#index'
      route '/zoo' => 'default#zoo', :layout => :default
      mount '/admin' => :backend
      Alfa::Router.context :app => :backend do
        route '/' => 'kfk#index', :layout => :fantastic
      end
    end
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
    assert_equal(
        [
            {:rule=>"/~assets/:path**", :options=>{:type=>:asset}},
            {:rule=>'/', :options=>{:controller=>:default, :action=>:index}},
            {:rule=>'/zoo', :options=>{:controller=>:default, :action=>:zoo, :layout => :default}},
            {:context=>{:app=>{:path=>'/admin/', :app=>:backend, :options=>{}}},
             :routes=>[
                 {:rule=>'/', :options=>{:controller=>:kfk, :action=>:index, :layout=>:fantastic}}
             ]},
        ],
        Alfa::Router.instance_variable_get(:@routes)
    )
  end

  # alternative route format with real files
  def test_08
    Alfa::Router.reset
    Alfa::Router.apps_dir = File.expand_path('../data/test_router/2/apps', __FILE__)
    load File.expand_path('../data/test_router/2/config/routes.rb', __FILE__)
    assert_equal(
        [
            {:rule=>"/~assets/:path**", :options=>{:type=>:asset}},
            {:context=>{:app=>{:path=>"/admin/", :app=>:backend, :options=>{}}},
             :routes=>[
                 {:rule=>"/", :options=>{:controller=>:main, :action=>:index, :layout=>:index}},
                 {:rule=>"/:controller", :options=>{:action=>:index}}
             ]},
            {:context=>{:app=>{:path=>"/", :app=>:frontend, :options=>{}}},
             :routes=>[
                 {:rule=>"/", :options=>{:controller=>:main, :action=>:index, :layout=>:index}},
                 {:rule=>"/:action", :options=>{:controller=>:main, :layout=>:internal}},
                 {:rule=>"/:controller/:action", :options=>{:layout=>:internal}},
                 {:rule=>"/:controller/:action/:id", :options=>{:layout=>:internal}},
             ]},
        ],
        Alfa::Router.instance_variable_get(:@routes)
    )
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
  end
end
