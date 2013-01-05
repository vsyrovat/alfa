Project::WebApplication.routes.draw do
  route '/' => 'default#index'
  route '/:action', :controller => :default
end