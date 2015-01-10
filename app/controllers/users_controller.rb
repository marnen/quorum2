# coding: UTF-8

class UsersController < ApplicationController
  layout :get_layout
  before_filter :require_user, :only => [:edit, :regenerate_key]
  # render new.html.haml
  def new
  end

  def create
    @user = User.new user_params
    @user.save
    if @user.errors.empty?
      @user.activate # so we don't have to go through activation right now
      UserSession.create @user
      redirect_back_or_default('/login')
      # The next line should be uncommented when we go through e-mail activation.
      # flash[:notice] = "Thanks for signing up! Please check your e-mail for activation instructions."
    else
      render :action => 'new'
    end
  end

  # TODO: split into edit and update!
  def edit
    if request.post?
      if user_params[:password].nil? and user_params[:password_confirmation].nil?
        # bypass encryption if both passwords are blank:
        # User.encrypt_password will not change anything if password is empty
        user_params[:password] = ''
        user_params[:password_confirmation] = ''
      end
      @user = current_user # User.find(params[:id].to_i)
      @user.update_attributes(user_params)
      @user.update_attribute(:coords, nil)
      if @user.errors.empty?
        flash[:notice] = _("Your changes have been saved.")
        redirect_to root_url and return
      else
        render :action => 'new'
      end
    else
      @user = current_user # params[:id].nil? ? User.current_user : User.find(params[:id].to_i)
      @page_title = _("Edit profile")
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = _("Signup complete!")
    end
    redirect_back_or_default('/login')
  end

  # Regenerates #single_access_token of current_user, then redirects to previous page.
  def regenerate_key
    u = current_user
    begin
      u.reset_single_access_token!
      flash[:notice] = _('Your RSS URL has been regenerated.')
    rescue Exception
      flash[:error] = _("Couldn't regenerate the URL! Please try again.")
    ensure
      redirect_to :back
    end
  end

  # Resets password of user specified in <tt>params[:email]</tt>, and sends the new password to the user by e-mail.
  def reset
    if request.post?
      user = User.find_by_email(params[:email])
      if user.nil?
        flash[:error] = _("Couldn't find that e-mail address!")
        return
      end
      begin
        user.reset_password!
        UserMailer.reset(user).deliver
        flash[:notice] = _("Password reset for %{email}. Please check your e-mail for your new password.") % {:email => params[:email]}
      #rescue
        #flash[:error] = _("Couldn't reset password. Please try again.")
        #return
      end
    else
      @page_title = _("Reset password")
    end
    current_user_session.try :destroy
  end

 protected
  # Returns the name of the layout we should be using. This enables us to have different layouts depending on whether a user is logged in.
  def get_layout
    current_user ? "standard" : "unauthenticated"
  end

  def user_params
    params.require(:user).permit *User.permitted_params
  end
end
