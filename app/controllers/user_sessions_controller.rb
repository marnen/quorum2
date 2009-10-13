# This controller handles the login/logout function of the site.  
class UserSessionsController < ApplicationController
  layout 'unauthenticated'
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  # render new.rhtml
  def new
    @page_title = _("Login")
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = _("Logged in successfully!")
      redirect_back_or_default root_url
    else
      flash[:error] = _("Couldn't log in with that information!")
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default new_user_session_url
  end
end
