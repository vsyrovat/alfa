require 'test/unit'
require 'alfa/application'
require 'alfa/config'

class AlfaApplicationTest < Test::Unit::TestCase
  def test_01 # base test
    assert Alfa::VARS.is_a?(Hash), "Alfa::VARS expected to be a Hash"
    assert_raise NoMethodError do
      application = Alfa::Application.new
    end
    assert Alfa::Application.respond_to?(:init!)
    assert Alfa::Application.respond_to?(:load_tasks)
    assert Alfa::Application.respond_to?(:config)
  end

  def test_02 # Alfa::Application.config
    assert Alfa::Application.config.is_a?(Alfa::Config)
    Alfa::Application.config :foo => 1
    assert_equal(1, Alfa::Application.config[:foo])
    Alfa::Application.config[:bar] = 2
    assert_equal(2, Alfa::Application.config[:bar])
  end

  # test config.project_root
  def test_03
    assert_raise Alfa::Exceptions::E001, "Application requires config.project_root" do
      Alfa::Application.init!
    end
    assert_raise Alfa::Exceptions::E001, "Application's project_root should not be nil" do
      Alfa::Application.config[:project_root] = nil
      Alfa::Application.init!
    end
    assert_nothing_raised Exception, "Application should silent init when project_root is set" do
      Alfa::Application.config[:project_root] = File.expand_path('../data/test_application', __FILE__)
      Alfa::Application.init!
    end
  end
end
