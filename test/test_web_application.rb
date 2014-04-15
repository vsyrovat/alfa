require 'test/unit'
require 'alfa/web_application'

class TestAlfaWebApplication < Test::Unit::TestCase
  # basics
  def test_01
    assert Alfa::WebApplication.respond_to?(:call), "WebApplication should be callable for Rack"
    assert Alfa::WebApplication.ancestors.include?(Alfa::Application), "WebApplication should be subclass of Application"
  end


  def test_02
    prepare_web_application
    assert_raise Alfa::Exceptions::E002, "config[:document_root] should be defined" do
      Alfa::WebApplication.config.delete(:document_root)
      Alfa::WebApplication.init!
    end
    prepare_web_application
    assert_raise Alfa::Exceptions::E002, "config[:templates_priority] should be defined" do
      Alfa::WebApplication.config.delete(:templates_priority)
      Alfa::WebApplication.init!
    end
    prepare_web_application
    assert_raise Alfa::Exceptions::E001, "config[:groups] should be a hash" do
      Alfa::WebApplication.config.delete(:groups)
      Alfa::WebApplication.init!
    end
    prepare_web_application
    assert_nothing_raised Exception do
      Alfa::WebApplication.config[:document_root] = File.expand_path('../data/test_web_application/public', __FILE__)
      Alfa::WebApplication.init!
    end
  end


  def prepare_web_application
    Alfa::WebApplication.config[:project_root] = File.expand_path('../data/test_web_application', __FILE__)
    Alfa::WebApplication.config[:document_root] = File.expand_path('../data/test_web_application/public', __FILE__)
    Alfa::WebApplication.config[:templates_priority] = [:haml]
    Alfa::WebApplication.config[:groups] = {public: []}
    Alfa::WebApplication.init!
  end


  def test_03
    prepare_web_application
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
    assert_equal(200, Alfa::WebApplication.call({'PATH_INFO' => '/'})[0])
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO' => '/404'})[0])
    assert_equal(200, Alfa::WebApplication.call({'PATH_INFO' => '/bar'})[0])
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO' => '/methods'})[0])
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO' => '/inspect'})[0])
  end

  # Controllers isolation (admin/DefaultController, frontend/DefaultController):
  # same name variables should be independent
  def test_04
    prepare_web_application
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
    assert_equal("Frontend\n", Alfa::WebApplication.call({'PATH_INFO'=>'/test_04'})[2].join)
    assert_equal("Admin\n", Alfa::WebApplication.call({'PATH_INFO'=>'/admin/test_04'})[2].join)
    assert_equal("Frontend\n", Alfa::WebApplication.call({'PATH_INFO'=>'/test_04'})[2].join) # call controller after calling same name controller should not interleave controller variables
    assert_equal("Admin\n", Alfa::WebApplication.call({'PATH_INFO'=>'/admin/test_04'})[2].join)
  end

  # Controllers isolation (admin/DefaultController, frontend/DefaultController):
  # action, defined in first controller and not defined in second controller should not be called with second controller
  def test_05
    prepare_web_application
    assert_equal(200, Alfa::WebApplication.call({'PATH_INFO'=>'/frontend_only'})[0]) # defined in frontend/DefaultController
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO'=>'/admin/frontend_only'})[0]) # not defined in admin/DefaultController
  end

  # Threads isolation (thread safe)
  # Controller's variables should be set independently on simultaneous calls
  def test_08
    prepare_web_application
    r1 = Alfa::WebApplication.call({'PATH_INFO'=>'/test_08'}) do |controller1, template1|
      r2 = Alfa::WebApplication.call({'PATH_INFO'=>'/admin/test_08'}) do |controller2, template2|
        assert_not_equal(controller1.hash, controller2.hash)
        assert_not_equal(controller1.request.hash, controller2.request.hash)
        assert_not_equal(controller1.session.hash, controller2.session.hash)
        assert_equal(:bar, controller1.session[:foo])
        assert_equal(:baz, controller2.session[:foo])
      end
      assert_equal("/admin/test_08\n/admin/test_08", r2[2].join.strip)
    end
    assert_equal("/test_08\n/test_08", r1[2].join.strip)

    prepare_web_application
    c1 = c2 = foo1 = foo2 = r1 = r2 = nil
    r1 = Alfa::WebApplication.call({'PATH_INFO'=>'/test_08a'}) do |controller1, template1|
      r2 = Alfa::WebApplication.call({'PATH_INFO'=>'/admin/test_08a'}) do |controller2, template2|
        c1 = controller1
        c2 = controller2
        assert_not_equal(controller1.hash, controller2.hash)
        assert_not_equal(controller1.request.hash, controller2.request.hash)
        foo1 = controller1.session[:foo]
        foo2 = controller2.session[:foo]
      end
    end
    assert_equal(c2.hash.to_s, r2[2].join.strip)
    assert_equal(c1.hash.to_s, r1[2].join.strip)
    assert_equal(:far, foo1)
    assert_equal(:faz, foo2)
  end
end
