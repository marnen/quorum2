class EventController < ApplicationController
  layout "standard", :except => :export # no layout needed on export, since it generates an iCal file
  before_filter :login_required
  after_filter :ical_header, :only => :export # assign the correct MIME type so that it gets recognized as an iCal event
  
  def list
    @events = Event.find(:all, :order => :date)
    @page_title = _("Upcoming events")
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

  def edit
    @page_title = _("Edit event")
    
    begin
      @event ||= Event.find(params[:id].to_i)
    rescue
      flash[:error] = _("Couldn't find any event to edit!")
      redirect_to(:action => :list) and return
    end
    
    if request.post?
      if @event.update_attributes(params[:event]) and @event.update_attribute(:coords, nil)
        flash[:notice] = _("Your event has been saved.")
        redirect_to :action => :list and return
      end
    end
    render :action => :new
  end
  
  def export
    # export to iCalendar format
    begin
      @event = Event.find(params[:id].to_i)
      render :template => 'event/ical.ics.erb'
    rescue
      flash[:error] = _("Couldn't find any event to export!")
      redirect_to(:action => :list) and return
    end
  end

  def change_status
    id = params[:id]
    status_map = {'yes' => true, 'no' => false, 'maybe' => nil}
    if !id.nil? then
      event = Event.find_by_id(id)
      commitment = event.commitments.find_or_create_by_user_id(current_user.id)
      commitment.status = status_map[params[:status].to_s]
      commitment.save!
    end
    redirect_to :action => :list
  end
  
  def map
    begin
      @event = Event.find(params[:id])
      @host = request.host_with_port
    rescue
      flash[:error] = _("Couldn't find that event!")
      redirect_to(:action => :list) and return
    end
    @page_title = _("Map for %s" % @event.name)
  end
  
 protected
  def ical_header
    # set MIME type for iCal
    headers['Content-Type'] = 'text/calendar'
  end
end
