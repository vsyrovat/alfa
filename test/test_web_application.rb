require 'test/unit'
require 'alfa/web_application'

class TestAlfaWebApplication < Test::Unit::TestCase
  # basics
  def test_01
    assert Alfa::WebApplication.respond_to?(:call), "WebApplication should be callable for Rack"
    assert Alfa::WebApplication.ancestors.include?(Alfa::Application), "WebApplication should be subclass of Application"
  end


  def test_02
    Alfa::WebApplication.config[:project_root] = File.expand_path('../data/test_web_application', __FILE__)
    assert_raise Alfa::Exceptions::E002, "WebApplication requires config.document_root" do
      Alfa::WebApplication.config.delete(:document_root)
      Alfa::WebApplication.init!
    end
    assert_raise Alfa::Exceptions::E002, "WebApplication's document_root should not be nil" do
      Alfa::WebApplication.config[:document_root] = nil
      Alfa::WebApplication.init!
    end
    assert_nothing_raised Exception do
      Alfa::WebApplication.config[:document_root] = File.expand_path('../data/test_web_application/public', __FILE__)
      Alfa::WebApplication.init!
    end
  end


  def test_03
    Alfa::WebApplication.config[:project_root] = File.expand_path('../data/test_web_application', __FILE__)
    Alfa::WebApplication.config[:document_root] = File.expand_path('../data/test_web_application/public', __FILE__)
    Alfa::WebApplication.init!
    #puts Alfa::Router.instance_variable_get(:@routes).inspect
    assert_equal(200, Alfa::WebApplication.call({'PATH_INFO' => '/'})[0])
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO' => '/404'})[0])
    assert_equal(200, Alfa::WebApplication.call({'PATH_INFO' => '/bar'})[0])
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO' => '/methods'})[0])
    assert_equal(404, Alfa::WebApplication.call({'PATH_INFO' => '/inspect'})[0])
  end
end
