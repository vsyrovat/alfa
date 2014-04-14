class DefaultController < Alfa::Controller
  def index
    redirect href('@auth', :params=>{:return_to=>href(:index)}) unless grant?(:admin)
    @h1 = 'Admin'
  end

  def foo

  end
end
