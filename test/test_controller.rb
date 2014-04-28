require 'test/unit'
require 'alfa/controller'
require 'alfa/exceptions'

class TestAlfaController < Test::Unit::TestCase
  def test_01
    eval <<EOL
class Z < Alfa::Controller
  def some_action
    @foo = :bar
  end
  def other_action
    @fuu = :baz
  end
end
EOL
    z = Z.new
    z.some_action
    assert_equal({:@foo=>:bar}, z._instance_variables_hash.except(:@route))
    z.other_action
    assert_equal({:@foo=>:bar, :@fuu=>:baz}, z._instance_variables_hash.except(:@route))
  end

  # _string_to_aca
  def test_02
    c = Alfa::Controller.new
    assert_equal({:action=>:foo}, c._string_to_aca('foo'))
    assert_equal({:action=>:foo, :controller=>:default}, c._string_to_aca('default#foo'))
    assert_equal({:app=>:admin, :controller=>:default, :action=>:foo}, c._string_to_aca('default#foo@admin'))
    assert_equal({:app=>:admin}, c._string_to_aca('@admin'))
    assert_raise Alfa::Exceptions::E004 do c._string_to_aca('default#foo@admi@n') end
    assert_raise Alfa::Exceptions::E004 do c._string_to_aca('de#fault#foo@admin') end
    assert_raise Alfa::Exceptions::E004 do c._string_to_aca('#default#f#oo@admin') end
  end

  # _extract_href_params
  def test_03
    c = Alfa::Controller.new
    c.app_sym = :frontend
    c.c_sym = :default
    assert_equal({:app=>:frontend, :controller=>:default, :action=>:foo}, c._extract_href_params(:action=>:foo))
    assert_equal({:app=>:frontend, :controller=>:default, :action=>:foo}, c._extract_href_params(:action=>:foo, :controller=>:default))
    assert_equal({:app=>:frontend, :controller=>:default, :action=>:foo}, c._extract_href_params(:foo))
    assert_equal({:app=>:frontend, :controller=>:default, :action=>:foo}, c._extract_href_params('foo'))
    assert_equal({:app=>:frontend, :controller=>:admin, :action=>:foo}, c._extract_href_params('admin#foo'))
    assert_equal({:app=>:zoo, :controller=>:admin, :action=>:foo}, c._extract_href_params('admin#foo', :app=>:zoo))
    assert_equal({:app=>:zoo, :controller=>:admin, :action=>:foo}, c._extract_href_params('admin#foo@zoo'))
    assert_equal({:app=>:admin}, c._extract_href_params(:app=>:admin))
  end
end
