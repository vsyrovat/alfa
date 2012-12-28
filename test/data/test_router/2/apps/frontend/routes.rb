Alfa::Router.draw do
  route '/' => 'main#index', :layout => :index
  route '/:action', :controller => :main, :layout => :internal
  route '/:controller/:action', :layout => :internal
  route '/:controller/:action/:id', :layout => :internal
end
