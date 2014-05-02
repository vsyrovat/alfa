require 'test/unit'
require 'alfa/config'

class AlfaConfigTest < Test::Unit::TestCase
  def test_01
    config = Alfa::Config.new
    assert config.is_a?(Hash)
    assert config[:db].is_a?(Hash)
    assert config[:log].is_a?(Hash)
    assert_raise RuntimeError do
      config[:db] = nil
    end
    assert_raise RuntimeError do
      config.store(:db, nil)
    end
    assert_raise RuntimeError do
      config[:log] = nil
    end
    assert_raise RuntimeError do
      config.store(:log, nil)
    end
    assert_equal({:db=>{}, :log=>{}, :session=>{:key=>'session', :secret=>nil}}, config)
    config[:foo] = 1
    assert_equal({:db=>{}, :log=>{}, :session=>{:key=>'session', :secret=>nil}, :foo=>1}, config)
  end
end
