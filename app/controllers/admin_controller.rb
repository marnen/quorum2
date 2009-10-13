class AdminController < ApplicationController
  before_filter :check_admin
  layout 'standard'
  
  def index
    @page_title = _("Administrative tools")
    @calendars = current_user.permissions.find_all_by_role_id(admin, :include => :calendar).collect{|p| p.calendar}.sort{|x, y| x.name <=> y.name}
  end
  
end
