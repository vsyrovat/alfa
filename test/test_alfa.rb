require 'test/unit'
require 'alfa'

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
    assert_equal([true, {path: 'js/jquery/jquery-latest.js', type: :asset}], Alfa::WebApplication.route_match?('/~assets/:path**', '/~assets/js/jquery/jquery-latest.js'))

    # string rules, negative cases
    assert_equal([false, {action: 'foo'}], Alfa::WebApplication.route_match?('/:action', '/foo/'))
    assert_equal([false, {action: 'foo'}], Alfa::WebApplication.route_match?('/:action/', '/foo'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/foo/bar/', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/*', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/*/', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/*', '/foo/bar/'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/**/', '/foo/bar'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/**', '/foo/bar/'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/~assets/:path**', '/~assets/js/jquery/non-exists-file.js'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/~assets/:path**', '/~assets/js/jquery/'))
    assert_equal([false, {}], Alfa::WebApplication.route_match?('/~assets/:path**', '/~assets/js/jquery'))

    # regexp rules, positive cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([true, {controller: 'default', action: 'index'}], Alfa::WebApplication.route_match?(rule, '/default/index'))

    # regexp rules, negative cases
    rule = Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)?$')
    assert_equal([false, {}], Alfa::WebApplication.route_match?(rule, '/'))
  end

end