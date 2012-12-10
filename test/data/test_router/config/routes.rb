Alfa::Router.draw do
  mount '/admin/', :backend
  mount '/', :frontend
end
