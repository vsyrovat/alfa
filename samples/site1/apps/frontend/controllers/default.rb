class DefaultController < Alfa::Controller

  def index
    @session = session
    @user = user
  end

  def foo
    @var = 'value'
  end

end
