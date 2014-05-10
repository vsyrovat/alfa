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

  # Test for Regression of Hash#reject in Ruby 2.1.1
  # https://www.ruby-lang.org/en/news/2014/03/10/regression-of-hash-reject-in-ruby-2-1-1/
  # Should pass in Ruby 2.0.0 and 2.1.2+ (not in 2.1.1)
  def test_02
    eval <<EOL
class SubHash < Hash; end
EOL
    assert_equal(SubHash, SubHash.new.reject{}.class)
  end
end