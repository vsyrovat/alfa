class DefaultController < Alfa::Controller
  def index
  end

  def bar
  end

  def test_04
    @str = 'Frontend'
  end

  def frontend_only
  end

  def test_06
    @some_var = :some_value
  end

  def test_07
    @other_var = :other_value
  end
end