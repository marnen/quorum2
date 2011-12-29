# coding: UTF-8

class CalendarsController < ApplicationController
  @nonadmin ||= [:new, :create]
  before_filter :check_admin, :except => @nonadmin
  before_filter :require_user, :only => @nonadmin
  layout 'standard'

  respond_to :html

  def new
    @page_title = _('Create calendar')
    @calendar = Calendar.new
    respond_with @calendar
  end

  def edit
    @page_title = _('Edit calendar')
    @calendar = Calendar.find_by_id params[:id]
    respond_with @calendar
  end

  def create
    @calendar = Calendar.new params[:calendar]
    if @calendar.save!
      make_admin_permission_for @calendar
      redirect_to '/admin', notice: _('Your calendar was successfully created.')
    else
      flash[:error] = _("Couldn't create your calendar!")
      respond_with @calendar
    end
  end

  make_resourceful do
    actions :update

    response_for :update do
      flash[:notice] = _('Your calendar was successfully saved.')
      redirect_to '/admin'
    end

    response_for :update_fails do
      flash[:error] = _('Couldn\'t save your calendar!')
      redirect_to :back
    end
  end

  # Lists all the users for the current #Calendar.
  def users
    @page_title = _('Users for calendar %{calendar_name}') % {:calendar_name => current_object}
    @users = current_object.users.find(:all, :order => 'lastname, firstname')
  end

  private

  def make_admin_permission_for(calendar)
    p = User.current_user.permissions
    @admin ||= Role.find_or_create_by_name('admin')
    if !p.find_by_calendar_id_and_role_id(calendar.id, @admin.id)
      p << Permission.create!(:user => User.current_user, :calendar => calendar, :role => @admin)
    end
  end
end
