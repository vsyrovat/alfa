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

  # Controllers isolation:
  # variables, defined in controller, should not be accessible from other controllers
  def test_06
    prepare_web_application
    Alfa::WebApplication.call({'PATH_INFO'=>'/test_06'})
    Alfa::WebApplication.call({'PATH_INFO'=>'/admin/test_06'})
    assert_equal({:@some_var=>:some_value}, Alfa::WebApplication.instance_variable_get(:@controllers)[[:frontend, :default]]._instance_variables_hash.except(:@application, :@app_sym, :@c_sym))
    assert_equal({}, Alfa::WebApplication.instance_variable_get(:@controllers)[[:admin, :default]]._instance_variables_hash.except(:@application, :@app_sym, :@c_sym))
  end

  # Calls isolation
  # Controller's variables should be cleared before (or after) each call
  def test_07
    prepare_web_application
    Alfa::WebApplication.call({'PATH_INFO'=>'/test_06'})
    assert_equal({:@some_var=>:some_value}, Alfa::WebApplication.instance_variable_get(:@controllers)[[:frontend, :default]]._instance_variables_hash.except(:@application, :@app_sym, :@c_sym))
    Alfa::WebApplication.call({'PATH_INFO'=>'/test_07'})
    assert_equal({:@other_var=>:other_value}, Alfa::WebApplication.instance_variable_get(:@controllers)[[:frontend, :default]]._instance_variables_hash.except(:@application, :@app_sym, :@c_sym))
  end
end
