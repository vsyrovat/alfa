class DefaultController < Alfa::Controller
  def index
    @link_to_home = href :app=>:frontend
  end
end
