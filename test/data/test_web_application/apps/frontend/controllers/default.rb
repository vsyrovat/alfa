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

  def test_08
    @request = request
    @env = @request.env
    @path_info = @env['PATH_INFO']
    session[:foo] = :bar
    @link = href('test_08')
    response.headers['Param'] = 'value1'
  end

  def test_08a
    @controller = self
    session[:foo] = :far
    response.headers['Param'] = 'value2'
  end
end