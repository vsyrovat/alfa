#encoding: utf-8

class DefaultController < Alfa::Controller

  def index
    @session = session
    @user = user
  end

  def foo

  end

end
