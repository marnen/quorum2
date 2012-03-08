# coding: UTF-8

# This is the controller for #Event instances. It supports the following make_resourceful[http://mr.hamptoncatlin.com] actions: :index, :create, :new, :edit, :update, :show.
class EventsController < ApplicationController
  layout "standard", except: [:export, :feed] # no layout needed on export, since it generates an iCal file
  before_filter :require_user, except: :feed
  before_filter :login_from_key, only: :feed
  before_filter :load_event, only: [:edit, :update, :show, :delete]
  after_filter :ical_header, only: :export # assign the correct MIME type so that it gets recognized as an iCal event

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  respond_to :html, except: :feed
  respond_to :pdf, only: :index
  respond_to :rss, only: :feed

  def index
    set_table_headers
    @events = current_objects
    respond_with @events do |format|
      format.pdf do
        @users = current_objects.blank? ? [] : current_objects[0].calendar.permissions.find_all_by_show_in_report(true, :include => :user).collect{|x| x.user}.sort # TODO: fix for multiple calendars
        prawnto prawn: {page_layout: :landscape}
        render layout: false
      end
    end
  end

  def new
    @page_title = _("Add event")
    @event = Event.new
    respond_with @event
  end

  def create
    @event = Event.new params[:event]
    respond_with_flash { @event.save }
  end

  def edit
    if @event.allow? :edit
      @page_title = _("Edit event")
      respond_with @event
    else
      redirect_to({action: :index}, flash: {error: _("You are not authorized to edit that event.")})
    end
  end

  def update
    respond_with_flash { @event.update_attributes params[:event] }
  end

  def show
    if @event.allow? :show
      @page_title = @event.name
      respond_with @event
    else
      redirect_to({action: :index}, flash: {error: _("You are not authorized to view that event.")})
    end
  end

  # Generate an RSS feed of events.
  def feed
    respond_to do |format|
      format.rss do
        params[:from_date] = Date.civil(1, 1, 1)
        @key = params[:key]
        @events = current_objects
      end
    end
  end

# Delete an #Event, subject to #Event#allow?.
  def delete
    begin
      if @event.allow?(:delete)
        @event.hide
        flash[:notice] = _("The selected event was deleted.")
      else
        flash[:error] = _("You are not authorized to delete that event.")
      end
    rescue
      flash[:error] = _("Couldn't find any event to delete!")
    end
    redirect_to(:action => :index) and return
  end

  # Export #Event to iCalendar format.
  def export
    begin
      @event = Event.find(params[:id].to_i)
      render :template => 'events/ical.ics.erb'
    rescue
      flash[:error] = _("Couldn't find any event to export!")
      redirect_to(:action => :index) and return
    end
  end

  # Change current #User's attendance status for the current #Event.
  def change_status
    id = params[:id]
    status_map = {'yes' => true, 'no' => false, 'maybe' => nil}
    if !id.nil? then
      event = Event.find_by_id(id)
      event.change_status! current_user, status_map[params[:status].to_s], params[:comment]
    end
    if request.xhr?
      render :partial => 'event', :locals => {:event => event}
    else
      redirect_to :action => :index
    end
  end

  # Display a map page for the current #Event.
  def map
    begin
      load_event
      @host = request.host_with_port
    rescue
      flash[:error] = _("Couldn't find that event!")
      redirect_to(:action => :index) and return
    end
    @page_title = _("Map for %{event}") % {:event => @event.name}
  end

  private

  # Return non-deleted events between params[:from_date] and params[:to_date], optionally ordered as specified by params[:order] and [:direction].
  def current_objects
    user = params[:feed_user] || User.current_user

    # Process parameters from the search form, if it was submitted.
    if params[:search].present?
      search = params[:search]
      search.extend(Search)
      ['to', 'from'].each do |s|
        date = "#{s}_date"
        params[:"#{date}"] = search.send(date.to_sym)
      end

      calendars = search[:calendar_id].blank? ? nil : search[:calendar_id]
    end

    order = params[:order] || 'date'
    from_date = params[:from_date] || Time.zone.today
    to_date = params[:to_date]
    direction = params[:direction] || 'asc'
    calendars ||= user.calendars.collect{|c| c.id}

    if to_date.present?
      date_query = 'date BETWEEN :from_date AND :to_date'
    else
      date_query = 'date >= :from_date'
    end

    # TODO: can we use more Arel and less literal SQL?
    @current_objects || Event.includes(:commitments => :user).where(["calendar_id IN (:calendars) AND #{date_query}", {:calendars => calendars, :from_date => from_date, :to_date => to_date}]).order("#{order} #{direction}")
  end

  # Return an HTTP header with proper MIME type for iCal.
  def ical_header
    headers['Content-Type'] = 'text/calendar'
  end

  def load_event
    @event = Event.find params[:id]
  end

  # Log user in based on single_access_token.
  def login_from_key
    params[:feed_user] = User.find_by_single_access_token(params[:key])
  end

  # Handler for #RecordNotFound.
  def record_not_found
    flash[:error] = _("Couldn't find any event to edit!")
    redirect_to(:action => :index) and return
  end

  def set_table_headers
    params[:order] ||= 'date' # isn't it enough to define this in routes.rb?
    params[:direction] ||= 'asc' # and this?
    @page_title = _("Upcoming events")
    @order = params[:order]
    @direction = params[:direction]
    @search = params[:search].extend(Search) if params[:search]
  end

  def respond_with_flash
    raise ArgumentError, 'no block specified' unless block_given?

    if yield
      redirect_to({action: :index}, notice: _("Your event has been saved."))
    else
      flash[:error] = _("We couldn't process that request. Please try again.")
      respond_with @event
    end
  end
end
