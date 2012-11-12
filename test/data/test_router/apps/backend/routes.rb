Alfa::Router.draw do
  route '/', :controller => :main, :action => :index, :layout => :admin
  route '/:controller', :action => :index
end
