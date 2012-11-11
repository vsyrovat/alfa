require 'test/unit'
require 'alfa/router'

class AlfaRouterTest < Test::Unit::TestCase
  def test_route_match
    # string rules, positive cases
    assert_equal([true, {}], Alfa::Router.route_match?('/', '/'))
    assert_equal([true, {action: 'foo'}], Alfa::Router.route_match?('/:action', '/foo'))
    assert_equal([true, {action: 'foo'}], Alfa::Router.route_match?('/:action/', '/foo/'))
    assert_equal([true, {controller: 'foo', action: 'bar'}], Alfa::Router.route_match?('/:controller/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/foo/bar', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/*/bar', '/foo/bar'))
    assert_equal([true, {action: 'bar'}], Alfa::Router.route_match?('/*/:action', '/foo/bar'))
    assert_equal([true, {}], Alfa::Router.route_match?('/**', '/foo/bar'))
    assert_equal([true, {controller: 'foo'}], Alfa::Router.route_match?('/:controller/**', '/foo/bar/baz'))
    assert_equal([true, {path: 'js/jquery/jquery-latest.js', type: :asset}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/jquery-latest.js'))

    # string rules, negative cases
    assert_equal([false, {action: 'foo'}], Alfa::Router.route_match?('/:action', '/foo/'))
    assert_equal([false, {action: 'foo'}], Alfa::Router.route_match?('/:action/', '/foo'))
    assert_equal([false, {}], Alfa::Router.route_match?('/foo/bar/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/*', '/foo/bar/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/**/', '/foo/bar'))
    assert_equal([false, {}], Alfa::Router.route_match?('/**', '/foo/bar/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/non-exists-file.js'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery/'))
    assert_equal([false, {}], Alfa::Router.route_match?('/~assets/:path**', '/~assets/js/jquery'))

    # regexp rules, positive cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([true, {controller: 'default', action: 'index'}], Alfa::Router.route_match?(rule, '/default/index'))

    # regexp rules, negative cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([false, {}], Alfa::Router.route_match?(rule, '/'))
  end
end