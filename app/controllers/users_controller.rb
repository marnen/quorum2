class UsersController < ApplicationController
  layout :get_layout
  before_filter :login_required, :only => :edit
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
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/login')
  end
  
  def list
    if User.current_user.role.name != 'admin'
      flash[:error] = _("You are not authorized to perform that action.")
    else
      @users = User.find(:all)
    end
  end
  
 protected
  def get_layout
    logged_in? ? "standard" : "unauthenticated"
  end
end
