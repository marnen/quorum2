class PermissionsController < ApplicationController
  @@nonadmin = :index, :subscribe
  before_filter :check_admin, :except => @@nonadmin
  before_filter :login_required, :only => @@nonadmin
  layout 'standard'
  
  make_resourceful do
    actions :index, :edit, :update, :destroy
    
    response_for :index do
      @page_title = _('Subscriptions')
      @permissions = User.current_user.permissions.find(:all, :include => [:calendar, :role])
      if @permissions.empty?
        @unsubscribed = Calendar.find(:all)
      else
        @unsubscribed = Calendar.find(:all, :conditions => ['id NOT IN (:permissions)', {:permissions => @permissions.collect{|p| p.calendar.id}}])
      end
    end
    
    response_for :update do
      flash[:notice] = _("Your changes have been saved.")
      go_back
    end
    
    response_for :update_fails do
      flash[:error] = _("Couldn't save changes!")
      go_back
    end
    
    response_for :destroy do
      flash[:notice] = _('You were successfully unsubscribed.')
      go_back
    end
    
    response_for :destroy_fails do
      flash[:error] = _("Something went wrong. Please try again.")
      go_back
    end
  end
  
  def subscribe
    begin
      current_model.create! do |p|
        p.calendar_id = params[:calendar_id]
        p.user = User.current_user
        p.role = Role.find_by_name('user')
      end
    rescue
      flash[:error] = _("Something went wrong. Please try again.")
      go_back
    end
    flash[:notice] = _("Your subscription has been saved.")
    go_back
  end
  
 protected
  def go_back
    begin
      redirect_to :back
    rescue
      redirect_to root_url
    end
  end
end
