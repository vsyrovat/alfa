Project::WebApplication.routes.draw do
  mount '/admin/', :admin
  mount '/', :frontend
end
