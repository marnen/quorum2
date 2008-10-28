# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'unauthenticated'
  
  # render new.rhtml
  def new
    @page_title = _("Login")
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = _("Logged in successfully")
    else
      flash[:error] = _("Couldn't log in with that information!")
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default('/')
  end
end
