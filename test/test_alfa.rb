require 'test/unit'
require 'alfa'

class DB1 < Alfa::Database::MySQL; end
class DB2 < Alfa::Database::MySQL; end

class AlfaTest < Test::Unit::TestCase
  def test_route_match
    # string rules, positive cases
    assert_equal([true, {}], Alfa::WebApplication.route_match?('/', '/'))
    assert_equal([true, {action: 'foo'}], Alfa::WebApplication.route_match?('/:action', '/foo'))
    assert_equal([true, {action: 'foo'}], Alfa::WebApplication.route_match?('/:action/', '/foo/'))
    assert_equal([true, {controller: 'foo', action: 'bar'}], Alfa::WebApplication.route_match?('/:controller/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::WebApplication.route_match?('/foo/bar', '/foo/bar'))
    assert_equal([true, {}], Alfa::WebApplication.route_match?('/*/bar', '/foo/bar'))
    assert_equal([true, {action: 'bar'}], Alfa::WebApplication.route_match?('/*/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::WebApplication.route_match?('/**', '/foo/bar'))
    assert_equal([true, {controller: 'foo'}], Alfa::WebApplication.route_match?('/:controller/**', '/foo/bar/baz'))

    # string rules, negative cases
    assert_equal([false, {action: 'foo'}], Alfa::WebApplication.route_match?('/:action', '/foo/'))
    assert_equal([false, {action: 'foo'}], Alfa::WebApplication.route_match?('/:action/', '/foo'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/foo/bar/', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/*', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/*/', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/*', '/foo/bar/'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/**/', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/**', '/foo/bar/'))

    # regexp rules, positive cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([true, {controller: 'default', action: 'index'}], Alfa::WebApplication.route_match?(rule, '/default/index'))

    # regexp rules, negative cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([false, {}], Alfa::WebApplication.route_match?(rule, '/'))
  end


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