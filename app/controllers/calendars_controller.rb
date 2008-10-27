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
end
