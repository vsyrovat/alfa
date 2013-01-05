Project::WebApplication.routes.draw do
  mount '/admin/', :admin
  mount '/auth/', :auth
  mount '/', :frontend
end
