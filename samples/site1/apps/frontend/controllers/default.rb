class DefaultController < Alfa::Controller

  def index
    @session = session
    @user1 = user
    @user2 = user
  end

  def foo
    @var = 'value'
  end

end
