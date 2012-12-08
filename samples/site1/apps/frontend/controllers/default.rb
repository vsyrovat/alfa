class DefaultController < Alfa::Controller

  def index
    @items = Foo.all.map(&:values)
    @name = 'Dico Tuco'
  end

end