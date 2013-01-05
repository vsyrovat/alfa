class DefaultController < Alfa::Controller
  def index
    redirect href('@auth', :params=>{:return_to=>href(:index)}) unless grant? :admin
    @link_to_home = href '@frontend'
  end

  def foo
  end
end
