class DefaultController < Alfa::Controller
  def index
    redirect href('@auth', :params=>{:return_to=>href(:index)}) unless grant?(:admin_index)
    @h1 = 'Admin'
  end

  def foo
    @h1 = 'Admin foo'
  end
end
