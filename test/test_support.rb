require 'test/unit'
require 'alfa/support'
require 'alfa/database/mysql'

class DB1 < Alfa::Database::MySQL; end
class DB2 < Alfa::Database::MySQL; end

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

  def test_inheritance
    DB1.host = 'localhost'
    DB2.host = 'otherhost'
    assert_equal('localhost', DB1.host)
    assert_equal('otherhost', DB2.host)
  end
end