# coding: UTF-8

class PermissionsController < ApplicationController
  @nonadmin = :index, :subscribe, :destroy
  before_filter :check_admin, except: @nonadmin
  before_filter :require_user, only: @nonadmin
  layout 'standard'

  respond_to :html

  class NotDeletableError < RuntimeError
  end

  rescue_from NotDeletableError do |e|
    flash[:error] = _("Couldn't delete that subscription!")
    go_back
  end

  def index
    @page_title = _('Subscriptions')
    @permissions = User.current_user.permissions.includes(:calendar, :role)
    if @permissions.empty?
      @unsubscribed = Calendar.find(:all)
    else
      @unsubscribed = Calendar.find(:all, :conditions => ['id NOT IN (:permissions)', {:permissions => @permissions.collect{|p| p.calendar.id}}])
    end
    respond_with @permissions
  end

  def destroy
    @permission = Permission.find params[:id]
    if @permission.user_id != User.current_user.id # TODO: should maybe create Permission#allow? and use it here, as we did on Events
      raise NotDeletableError.new
    end

    if @permission.destroy
      flash[:notice] = _('You were successfully unsubscribed.')
    else
      flash[:error] = _("Something went wrong. Please try again.")
    end
    go_back
  end

  def update
    Permission.find(params[:id]).update_attributes! params[:permission]
    go_back
  end

  def subscribe
    begin
      Permission.create! do |p|
        p.calendar_id = params[:calendar_id]
        p.user = User.current_user
        p.role = Role.find_or_create_by_name('user')
      end
    rescue
      flash[:error] = _("Something went wrong. Please try again.")
      go_back and return
    end
    flash[:notice] = _("Your subscription has been saved.")
    go_back and return
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
