class DefaultController < ApplicationController

  def index
    @items = Foo.all
    @name = 'Dico Tuco'
  end

end