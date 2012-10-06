require 'test/unit'
require 'alfa/support'

class AlfaSupportTest < Test::Unit::TestCase

  def test_capitalize_name
    assert_equal('Foo', Alfa::Support.capitalize_name(:foo))
    assert_equal('Foo', Alfa::Support.capitalize_name('foo'))
    assert_equal('Foo', Alfa::Support.capitalize_name('FOO'))
    assert_equal('Foo', Alfa::Support.capitalize_name('Foo'))
    assert_equal('FooBar', Alfa::Support.capitalize_name(:foo_bar))
    assert_equal('FooBar', Alfa::Support.capitalize_name('foo_bar'))
    assert_equal('FooBar', Alfa::Support.capitalize_name(:foo__bar))
    assert_equal('BarBaz', Alfa::Support.capitalize_name('foo/bar_baz'))
  end

end