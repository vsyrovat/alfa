Project::WebApplication.routes.draw do
  route '/', :controller => :default, :action => :index, :layout => :index
  route '/:action', :controller => :default, :layout => :index
end
