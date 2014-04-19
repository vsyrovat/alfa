Alfa::WebApplication.routes.draw do
  route '/:controller', :action => :index
  route '/:action', :controller => :default
end