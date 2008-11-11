# This is the controller for #Event instances. It supports the following make_resourceful[http://mr.hamptoncatlin.com] actions: :index, :create, :new, :edit, :update, :show.
class EventsController < ApplicationController
  layout "standard", :except => [:export, :feed] # no layout needed on export, since it generates an iCal file
  before_filter :login_required, :except => :feed
  before_filter :login_from_key, :only => :feed
  after_filter :ical_header, :only => :export # assign the correct MIME type so that it gets recognized as an iCal event
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  make_resourceful do
    actions :index, :create, :new, :edit, :update, :show
    
    response_for :index do
      params[:order] ||= 'date' # isn't it enough to define this in routes.rb?
      params[:direction] ||= 'asc' # and this?
      @page_title = _("Upcoming events")
      @order = params[:order]
      @direction = params[:direction]
      @search = params[:search]
      @query = request.query_string.blank? ? '' : "?#{request.query_string}"
      class << @search # NOTE: should we refactor this into a regular class?
        def method_missing(name)
          s = name.to_s
          if s =~ /_date$/
            return Date.civil(self[:"#{s}(1i)"].to_i, self[:"#{s}(2i)"].to_i, self[:"#{s}(3i)"].to_i)
          else
            return self[name]
          end
        end
      end
    end
   
    before :new do
      @page_title = _("Add event")
    end
    
    response_for :edit do
      if !current_object.allow?(:edit)
        flash[:error] = _("You are not authorized to edit that event.")
        redirect_to :action => :index
      else
        @page_title = _("Edit event")
        render :action => 'new'
      end
    end
    
    response_for :update, :create do
      flash[:notice] = _("Your event has been saved.")
      redirect_to :action => :index
    end
    
    response_for :show do
      if !current_object.allow?(:show)
        flash[:error] = _("You are not authorized to view that event.")
        redirect_to :action => :index
      else
        @page_title = current_object.name
      end
    end
  end
  
  # Generate an RSS feed of events.
  def feed
    respond_to do |format|
      format.rss do
        @key = params[:key]
        params[:from_date] = Date.civil(1, 1, 1)
      end
    end
  end
  
=begin  
  def list
    params[:order] ||= 'date' # isn't it enough to define this in routes.rb?
    params[:direction] ||= 'asc' # and this?
    @events = Event.find(:all, :order => "#{params[:order]} #{params[:direction]}", :conditions => 'deleted is distinct from true')
    @page_title = _("Upcoming events")
    @order = params[:order]
    @direction = params[:direction]
  end

  def new
    @event = Event.new(params[:event])
    @page_title = _("Add event")
    if request.post?
      if @event.save
        flash[:notice] = _("Your event has been saved.")
        redirect_to :action => :list
      end
    end
  end
=end

# Delete an #Event, subject to #Event#allow?.
  def delete
    event = Event.find(params[:id].to_i)
    begin
      if event.allow?(:delete)
        event.hide
        flash[:notice] = _("The selected event was deleted.")
      else
        flash[:error] = _("You are not authorized to delete that event.")
      end
    rescue
      flash[:error] = _("Couldn't find any event to delete!")
    end
    redirect_to(:action => :index) and return
  end

=begin
  def edit
    begin
      @event ||= Event.find(params[:id].to_i)
    rescue
      flash[:error] = _("Couldn't find any event to edit!")
      redirect_to(:action => :list) and return
    end
      
    if User.current_user.role.name != 'admin' and User.current_user != @event.created_by
      flash[:error] = _("You are not authorized to edit that event.")
      redirect_to :action => :list and return
    else
      @page_title = _("Edit event")
      if request.post?
        if @event.update_attributes(params[:event]) and @event.update_attribute(:coords, nil)
          flash[:notice] = _("Your event has been saved.")
          redirect_to :action => :list and return
        end
      end
      render :action => :new
    end
  end
=end
  
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
      commitment = event.commitments.find_or_create_by_user_id(current_user.id)
      commitment.status = status_map[params[:status].to_s]
      commitment.save!
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
      @event = Event.find(params[:id])
      @host = request.host_with_port
    rescue
      flash[:error] = _("Couldn't find that event!")
      redirect_to(:action => :index) and return
    end
    @page_title = _("Map for %{event}") % {:event => @event.name}
  end
  
  # Return non-deleted events between params[:from_date] and params[:to_date], optionally ordered as specified by params[:order] and [:direction]. Provided for use with make_resourceful[http://mr.hamptoncatlin.com].
  def current_objects
    if !params[:search].nil?
      search = params[:search]
      ['to', 'from'].each do |s|
        date = "#{s}_date"
        params[:"#{date}"] = case search[:"#{date}_preset"]
          when 'today'
            Time.zone.today
          when 'earliest'
            Date.civil(1, 1, 1) # do we really need an earlier date? :)
          when 'latest'
            nil
          when 'other'
            Date.civil(search[:"#{date}(1i)"].to_i, search[:"#{date}(2i)"].to_i, search[:"#{date}(3i)"].to_i)
          else
            raise "Illegal value for search[:#{date}_preset]: #{search[:"#{date}_preset"]}"
        end
      end

      calendars = search[:calendar_id].blank? ? nil : search[:calendar_id]
    end
    
    user = params[:feed_user] || User.current_user
    order = params[:order] || 'date'
    from_date = params[:from_date] || Time.zone.today
    to_date = params[:to_date]
    direction = params[:direction] || 'asc'
    calendars ||= user.calendars.collect{|c| c.id}
    
    if to_date == nil
      date_query = 'date >= :from_date'
    else
      date_query = 'date BETWEEN :from_date AND :to_date'
    end
    
    @current_objects || current_model.find(:all, :conditions => ['deleted is distinct from true AND calendar_id IN (:calendars) AND ' + date_query, {:calendars => calendars, :from_date => from_date, :to_date => to_date}], :order => "#{order} #{direction}")
  end
  
 protected
  # Return an HTTP header with proper MIME type for iCal.
  def ical_header
    headers['Content-Type'] = 'text/calendar'
  end
  
  # Log user in based on feed_key.
  def login_from_key
    params[:feed_user] = User.find_by_feed_key(params[:key])
  end
  
  # Handler for #RecordNotFound.
  def record_not_found
    flash[:error] = _("Couldn't find any event to edit!")
    redirect_to(:action => :index) and return
  end
end
