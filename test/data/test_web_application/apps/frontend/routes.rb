Alfa::WebApplication.routes.draw do
  route '/' => 'kfk#index'
  route '/:action', :controller => :kfk
end