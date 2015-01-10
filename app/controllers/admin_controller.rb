# coding: UTF-8

class AdminController < ApplicationController
  before_filter :check_admin
  layout 'standard'

  def index
    @page_title = _("Administrative tools")
    @calendars = current_user.permissions.where(role_id: admin).includes(:calendar).collect{|p| p.calendar}.sort{|x, y| x.name <=> y.name}
  end

end
