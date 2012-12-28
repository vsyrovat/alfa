Alfa::Router.draw do
  route '/' => 'main#index', :layout => :index
  route '/:controller', :action => :index
end
