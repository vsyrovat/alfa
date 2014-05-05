require 'test/unit'
require 'alfa/support'
require 'alfa/support/nil_operations'

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

  def test_string_strtr
    s = "AA BB"
    assert_equal("BB AA", s.strtr("AA" => "BB", "BB" => "AA"))
    assert_equal("AA BB", s)
    s = "AA BB"
    assert_equal("BB AA", s.strtr([["AA", "BB"], ["BB", "AA"]]))
    assert_equal("AA BB", s)
  end

  def test_string_strtr!
    s = "AA BB"
    assert_equal("BB AA", s.strtr!("AA" => "BB", "BB" => "AA"))
    assert_equal("BB AA", s)
    s = "AA BB"
    assert_equal("BB AA", s.strtr!([["AA", "BB"], ["BB", "AA"]]))
    assert_equal("BB AA", s)
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

  def test_nil_operations
    # addition
    assert_nil(NilKnown.new(nil))
    assert_equal([nil, nil], nil.to_nkn.to_ar2)
    assert_equal(1, NilKnown.new(1))
    assert_equal([1, 1], 1.to_nkn.to_ar2)

    a = NilKnown.new(1) + 1
    assert_equal(2, a)
    assert_equal(2, a.known)
    a = NilKnown.new(1) + nil
    assert_nil(a)
    assert_equal(1, a.known)
    a = NilKnown.new(nil) + 1
    assert_nil(a)
    assert_equal(1, a.known)
    a = NilKnown.new(nil) + nil
    assert_nil(a)
    assert_nil(a.known)

    a = NilKnown.new(1) + NilKnown.new(1)
    assert_equal(2, a)
    assert_equal(2, a.known)
    a = NilKnown.new(1) + NilKnown.new(nil)
    assert_nil(a)
    assert_equal(1, a.known)
    a = NilKnown.new(nil) + NilKnown.new(1)
    assert_nil(a)
    assert_equal(1, a.known)
    a = NilKnown.new(nil) + NilKnown.new(nil)
    assert_nil(a)
    assert_nil(a.known)

    a = 1.to_nkn
    b = 2.to_nkn
    c = a + b
    assert_not_equal(c.hash, a.hash)
    assert_not_equal(c.hash, b.hash)

    assert_equal(1.1, NilKnown.new(1.1))

    a = NilKnown.new(1.1) + 1.1
    assert_equal(2.2, a)
    assert_equal(2.2, a.known)
    a = NilKnown.new(1.1) + nil
    assert_nil(a)
    assert_equal(1.1, a.known)
    a = NilKnown.new(nil) + 1.1
    assert_nil(a)
    assert_equal(1.1, a.known)
    a = NilKnown.new(nil) + nil
    assert_nil(a)
    assert_nil(a.known)

    a = NilKnown.new(1.1) + NilKnown.new(1.1)
    assert_equal(2.2, a)
    assert_equal(2.2, a.known)
    a = NilKnown.new(1.1) + NilKnown.new(nil)
    assert_nil(a)
    assert_equal(1.1, a.known)
    a = NilKnown.new(nil) + NilKnown.new(1.1)
    assert_nil(a)
    assert_equal(1.1, a.known)
    a = NilKnown.new(nil) + NilKnown.new(nil)
    assert_nil(a)
    assert_nil(a.known)

    assert_raise ::ArgumentError do
      NilKnown.new(1, 2)
    end

    assert_equal([nil, 102], (NilKnown.new(nil, 100) + 2).to_ar2)
    assert_equal([nil, 202], (NilKnown.new(nil, 100) + NilKnown.new(nil, 102)).to_ar2)

    # multiplication
    assert_equal([nil, 0], (1.to_nkn * nil).to_ar2)
    assert_equal([2, 2], (1.to_nkn * 2.to_nkn).to_ar2)
    assert_equal([nil, 24], (4.to_nkn * NilKnown.new(nil, 6)).to_ar2)

    # other
    assert(1.to_nkn.is?)
    assert(0.to_nkn.is?)
    assert(!nil.to_nkn.is?)
    assert(1.1.to_nkn.is?)
  end
end
