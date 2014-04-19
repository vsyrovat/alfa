Alfa::WebApplication.routes.draw do
  route '/' => 'default#index'
  route '/:action', :controller => :default
  route '/:controller', :action => :index
end