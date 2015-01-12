# coding: UTF-8

class CalendarsController < ApplicationController
  @nonadmin ||= [:new, :create]
  before_filter :check_admin, :except => @nonadmin
  before_filter :load_calendar, :except => @nonadmin
  before_filter :require_user, :only => @nonadmin
  layout 'standard'

  respond_to :html

  require 'resource_params'
  include ResourceParams

  def new
    @page_title = _('Create calendar')
    @calendar = Calendar.new
    respond_with @calendar
  end

  def create
    @calendar = Calendar.new resource_params
    if @calendar.save
      make_admin_permission_for @calendar
      redirect_to '/admin', notice: _('Your calendar was successfully created.')
    else
      flash[:error] = _("Couldn't create your calendar!")
      respond_with @calendar
    end
  end

  def edit
    @page_title = _('Edit calendar')
    respond_with @calendar
  end

  def update
    if @calendar.update_attributes resource_params
      redirect_to '/admin', notice: _('Your calendar was successfully saved.')
    else
      flash[:error] = _('Couldn\'t save your calendar!')
      respond_with @calendar
    end
  end

  # Lists all the users for the current #Calendar.
  def users
    @page_title = _('Users for calendar %{calendar_name}') % {:calendar_name => @calendar}
    @users = @calendar.users.order :lastname, :firstname
  end

  private

  def load_calendar
    @calendar = Calendar.find params[:id]
  end

  def make_admin_permission_for(calendar)
    p = User.current_user.permissions
    @admin ||= Role.find_or_create_by(name: 'admin')
    if !p.find_by_calendar_id_and_role_id(calendar.id, @admin.id)
      p << Permission.create!(:user => User.current_user, :calendar => calendar, :role => @admin)
    end
  end
end
