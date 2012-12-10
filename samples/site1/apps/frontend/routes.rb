WebApplication.routes.draw do

  route '/', :controller => :default, :action => :index, :layout => :index
  route '/:action', :controller => :default, :layout => :internal
  route '/:controller/:action', :layout => :internal
  route '/:controller/:action/:id', :layout => :internal
  #route Regexp.new('^/(?<controller>[^/]+)/(?<action>[^/]+)/(?<id>\d+)/?$')
  #route '/**', :controller => :default, :action => :other


  route 404, controller: :system, action: :page_404
  route 500, controller: :system, action: :page_500

end
