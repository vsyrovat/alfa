class DefaultController < Alfa::Controller

  def index
    @items = Foo.all
    @name = 'Dico Tuco'
  end

end