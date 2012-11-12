Alfa::Router.draw do
  route '/', :controller => :main, :action => :index, :layout => :index
  route '/:action', :controller => :main, :layout => :internal
  route '/:controller/:action', :layout => :internal
  route '/:controller/:action/:id', :layout => :internal
end
