#encoding: utf-8

class DefaultController < Alfa::Controller

  def index
    @items = Foo.all.map(&:values)
    @name = 'String from controller / Строка из контроллера'
    @link_to_admin = href(:app=>:admin)
    @link_to_foo = href :foo
    @link_to_admin_foo = href 'admin*default#foo'
  end

  def foo

  end

end
