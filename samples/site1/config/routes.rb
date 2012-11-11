WebApplication.routes.draw do
  mount :at => '/admin/', :app => :admin, :as => :admin
  mount :at => '/', :app => :frontend, :as => nil
end