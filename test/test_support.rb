require 'test/unit'
require 'alfa/support'
require 'alfa/database/mysql'

class DB1 < Alfa::Database::MySQL; end
class DB2 < Alfa::Database::MySQL; end

class AlfaSupportTest < Test::Unit::TestCase
  def test_camelcase_name
    assert_equal('Foo', Alfa::Support.camelcase_name(:foo))
    assert_equal('Foo', Alfa::Support.camelcase_name('foo'))
    assert_equal('Foo', Alfa::Support.camelcase_name('FOO'))
    assert_equal('Foo', Alfa::Support.camelcase_name('Foo'))
    assert_equal('FooBar', Alfa::Support.camelcase_name(:foo_bar))
    assert_equal('FooBar', Alfa::Support.camelcase_name('foo_bar'))
    assert_equal('FooBar', Alfa::Support.camelcase_name(:foo__bar))
    assert_equal('BarBaz', Alfa::Support.camelcase_name('foo/bar_baz'))
  end

  def test_inheritance
    DB1.host = 'localhost'
    DB2.host = 'otherhost'
    assert_equal('localhost', DB1.host)
    assert_equal('otherhost', DB2.host)
  end

  def test_parse_arguments
    assert_equal([[], {}], Alfa::Support.parse_arguments())
    assert_equal([[1, 2], {}], Alfa::Support.parse_arguments(1, 2))
    assert_equal([[1, 2], {3=>4}], Alfa::Support.parse_arguments(1, 2, 3=>4))
    assert_equal([[1, 2], {3=>4}], Alfa::Support.parse_arguments(1, 2, {3=>4}))
    assert_equal([[], {3=>4}], Alfa::Support.parse_arguments(3=>4))
    assert_equal([[1, 2], {3=>4, 5=>6}], Alfa::Support.parse_arguments(1, 2, 3=>4, 5=>6))
    assert_equal([[], {3=>4, 5=>6}], Alfa::Support.parse_arguments(3=>4, 5=>6))
    assert_equal([[[]], {}], Alfa::Support.parse_arguments([]))
    assert_equal([[], {}], Alfa::Support.parse_arguments({}))
  end

  def test_strtr
    assert_equal("BB AA", "AA BB".strtr("AA" => "BB", "BB" => "AA"))
    assert_equal("BB AA", "AA BB".strtr([["AA", "BB"], ["BB", "AA"]]))
  end
end
