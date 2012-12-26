require 'test/unit'
require 'alfa/web_application'

class TestAlfaWebApplication < Test::Unit::TestCase
  # basics
  def test_01
    assert Alfa::WebApplication.respond_to?(:call), "WebApplication should be callable for Rack"
    assert Alfa::WebApplication.ancestors.include?(Alfa::Application), "WebApplication should be subclass of Application"
  end


  def _test_02
    Alfa::WebApplication.config[:project_root] = File.expand_path('../data/test_web_application', __FILE__)
    assert_raise Alfa::Exceptions::E002, "Application requires config.project_root" do
      Alfa::WebApplication.init!
    end
    assert_raise Alfa::Exceptions::E002, "Application's project_root should not be nil" do
      Alfa::WebApplication.config[:document_root] = nil
      Alfa::WebApplication.init!
    end
    assert_nothing_raised Exception do
      Alfa::WebApplication.config[:document_root] = File.expand_path('../data/test_web_application/public', __FILE__)
      Alfa::WebApplication.init!
    end
  end
end
