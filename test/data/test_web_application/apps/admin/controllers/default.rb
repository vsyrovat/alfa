class DefaultController < Alfa::Controller
  def test_04
    @str = 'Admin'
  end

  def test_06
  end

  def test_08
    @request = request
    @env = @request.env
    @path_info = @env['PATH_INFO']
    session[:foo] = :baz
    @link = href('test_08')
  end

  def test_08a
    session[:foo] = :faz
  end
end