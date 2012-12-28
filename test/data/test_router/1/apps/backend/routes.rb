Alfa::Router.draw do
  route '/', :controller => :main, :action => :index, :layout => :index
  route '/:controller', :action => :index
end
