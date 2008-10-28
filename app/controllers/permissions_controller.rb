class PermissionsController < ApplicationController
  @@nonadmin = :index
  before_filter :check_admin, :except => @@nonadmin
  before_filter :login_required, :only => @@nonadmin
  layout 'standard'
  
  make_resourceful do
    actions :index, :edit, :update
    
    response_for :index do
      @page_title = _('Subscriptions')
      @permissions = User.current_user.permissions.find(:all, :include => [:calendar, :role])
    end
    
    response_for :update do
      flash[:notice] = _("Your changes have been saved.")
      go_back
    end
    
    response_for :update_fails do
      flash[:error] = _("Couldn't save changes!")
      go_back
    end
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
