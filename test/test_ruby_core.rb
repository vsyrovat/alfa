require 'test/unit'

class RubyCoreTest < Test::Unit::TestCase
  # Inherited classes should use separate variables
  def test_01
    eval <<EOL
class A
  class << self
    attr_accessor :foo
  end
end
class B < A; end
class C < B; end
EOL
    A.foo = 1
    B.foo = 2
    C.foo = 3
    assert_equal(1, A.foo)
    assert_equal(2, B.foo)
    assert_equal(3, C.foo)
  end
end