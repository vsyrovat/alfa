#encoding: utf-8

class DefaultController < Alfa::Controller
  def index
    @hello = 'Hello, world!'
  end
end
