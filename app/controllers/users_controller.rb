class UsersController < ApplicationController
  layout :get_layout
  before_filter :login_required, :only => [:edit, :regenerate_key]
  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      @user.activate # so we don't have to go through activation right now
      self.current_user = @user
      redirect_back_or_default('/login')
      # The next line should be uncommented when we go through e-mail activation.
      # flash[:notice] = "Thanks for signing up! Please check your e-mail for activation instructions."
    else
      render :action => 'new'
    end
  end
  
  def edit
    if request.post?
      form = params[:user]
      if form[:password].nil? and form[:password_confirmation].nil?
        # bypass encryption if both passwords are blank:
        # User.encrypt_password will not change anything if password is empty
        form[:password] = ''
        form[:password_confirmation] = ''
      end
      @user = User.current_user # User.find(params[:id].to_i)
      @user.update_attributes(form)
      @user.update_attribute(:coords, nil)
      if @user.errors.empty?
        flash[:notice] = _("Your changes have been saved.")
        redirect_to root_url and return
      else
        render :action => 'new'
      end
    else
      @user = User.current_user # params[:id].nil? ? User.current_user : User.find(params[:id].to_i)
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
  
  # Regenerates #feed_key of #User.current_user, then redirects to previous page.
  def regenerate_key
    u = User.current_user
    begin
      u.feed_key = nil
      u.save!
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
      password = Digest::MD5.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)[0, 10]
      user.password = password
      user.password_confirmation = password
      begin
        user.save!
        Mailer.deliver_reset(user, password)
        flash[:notice] = _("Password reset for %{email}. Please check your e-mail for your new password.") % {:email => params[:email]}
      rescue
        flash[:error] = _("Couldn't reset password. Please try again.")
        return
      end
    else
      @page_title = _("Reset password")
    end
  end
  
 protected
  # Returns the name of the layout we should be using. This enables us to have different layouts depending on whether a user is logged in.
  def get_layout
    logged_in? ? "standard" : "unauthenticated"
  end
end
