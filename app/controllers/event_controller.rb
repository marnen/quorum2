class EventController < ApplicationController
  layout "standard"
  before_filter :login_required
  
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
      if @event.update_attributes(params[:event])
        flash[:notice] = _("Your event has been saved.")
        redirect_to :action => :list and return
      end
    end
    render :action => :new
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
end
