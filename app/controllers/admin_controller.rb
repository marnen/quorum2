class AdminController < ApplicationController
  before_filter :check_admin
  layout 'standard'
  
  def index
    @page_title = _("Administrative tools")
    @calendars = User.current_user.permissions.find_by_role_id(admin, :include => :calendar).to_a.collect{|p| p.calendar}
  end
  
  protected
  def check_admin
    if User.current_user.permissions.collect{|p| p.role.name}.include? 'admin'
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
  
  def admin
    @admin ||= Role.find_by_name('admin')
    @admin
  end
end
