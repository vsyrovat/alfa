class DefaultController < Alfa::Controller

  def index
    @session = session
    @user = user
    @groups = user.groups
    @grants = user.grants
  end

  def foo
    @var = 'value'
  end

end
