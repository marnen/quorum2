class CalendarsController < ApplicationController
  before_filter :check_admin
  layout 'standard'
  
  make_resourceful do
    actions :edit, :update
  end
  
  def users
    @page_title = _('Users for calendar %{calendar_name}') % {:calendar_name => current_object}
    @users = current_object.users.find(:all, :order => 'lastname, firstname')
  end
  
  protected
  def check_admin
    if admin?
      return true
    else
      flash[:error] = _('You are not authorized to perform that action.')
      begin
        redirect_to :back
      rescue
        redirect_to root_url
      end
    end
  end
end
