require 'test/unit'
require 'alfa/controller'

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
    assert_equal({:foo=>:bar}, z._instance_variables_hash)
    z.other_action
    assert_equal({:foo=>:bar, :fuu=>:baz}, z._instance_variables_hash)
  end
end
