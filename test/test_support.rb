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

  def test_underscore
    assert_equal('foo', Alfa::Support.underscore_name('Foo'))
    assert_equal('foo_bar', Alfa::Support.underscore_name('FooBar'))
    assert_equal('a_b_bar', Alfa::Support.underscore_name('ABBar'))
    assert_equal('foobar', Alfa::Support.underscore_name('foobar'))
    assert_equal('foo_bar', Alfa::Support.underscore_name('Foo_Bar'))
    assert_equal('foo_bar', Alfa::Support.underscore_name('Foo__Bar'))
    assert_equal('foo_bar', Alfa::Support.underscore_name('foo_bar'))
    assert_equal('foo_bar', Alfa::Support.underscore_name(:foo_bar))
    assert_equal('bar_baz', Alfa::Support.underscore_name('Foo/Bar_Baz'))
  end

  def test_inheritance
    DB1.host = 'localhost'
    DB2.host = 'otherhost'
    assert_equal('localhost', DB1.host)
    assert_equal('otherhost', DB2.host)
  end

  def test_args_kwargs
    assert_equal([[], {}], Alfa::Support.args_kwargs())
    assert_equal([[1, 2], {}], Alfa::Support.args_kwargs(1, 2))
    assert_equal([[1, 2], {3=>4}], Alfa::Support.args_kwargs(1, 2, 3=>4))
    assert_equal([[1, 2], {3=>4}], Alfa::Support.args_kwargs(1, 2, {3=>4}))
    assert_equal([[], {3=>4}], Alfa::Support.args_kwargs(3=>4))
    assert_equal([[1, 2], {3=>4, 5=>6}], Alfa::Support.args_kwargs(1, 2, 3=>4, 5=>6))
    assert_equal([[], {3=>4, 5=>6}], Alfa::Support.args_kwargs(3=>4, 5=>6))
    assert_equal([[[]], {}], Alfa::Support.args_kwargs([]))
    assert_equal([[], {}], Alfa::Support.args_kwargs({}))
  end

  def test_strtr
    assert_equal("BB AA", "AA BB".strtr("AA" => "BB", "BB" => "AA"))
    assert_equal("BB AA", "AA BB".strtr([["AA", "BB"], ["BB", "AA"]]))
  end

  def test_hash_delete!
    h = {:a=>1, :b=>2}
    h.delete!(:b)
    assert_equal({:a=>1}, h)
    h = {:a=>1, :b=>2, :c=>3}
    h.delete!(:b, :c)
    assert_equal({:a=>1}, h)
    h = {:a=>1, :b=>2, :c=>3}
    h.delete!(:b)
    assert_equal({:a=>1, :c=>3}, h)
  end

  def test_hash_except
    h = {:a=>1, :b=>2}
    assert_equal({:a=>1}, h.except(:b))
    assert_equal({:a=>1, :b=>2}, h)
    h = {:a=>1, :b=>2, :c=>3}
    assert_equal({:a=>1}, h.except(:b, :c))
    assert_equal({:a=>1, :b=>2, :c=>3}, h)
    assert_equal({:a=>1, :c=>3}, h.except(:b))
    assert_equal({:a=>1, :b=>2, :c=>3}, h)
  end
end
