class PermissionsController < ApplicationController
  before_filter :check_admin
  
  make_resourceful do
    actions :edit, :update
    
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