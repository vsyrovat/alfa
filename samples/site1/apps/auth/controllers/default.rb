class DefaultController < Alfa::Controller
  def index
    redirect href(:login, :params=>request.GET)
  end

  def login
    if request.post?
      if try_login(request.POST['login'].strip, request.POST['password'].strip)
        flash 'Login successed'
        redirect request.POST['return_to'] if request.POST['return_to']
      else
        flash 'Login failed'
        redirect href :login
      end
    else
      # show login form
      @return_to = request.GET['return_to']
    end
  end

  def registration
    if request.post?
      session[:was_registration] = true
      session[:registration_success], session[:registration_message] = try_register(request.POST['login'].strip, request.POST['password'].strip)
      redirect href(:postregistration, :params=>request.GET)
    end
  end

  def postregistration
    @was_registration = session[:was_registration]
    @is_success, @message = session[:registration_success], session[:registration_message]
  end

  def logout
  end
end