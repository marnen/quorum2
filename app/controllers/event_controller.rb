class EventController < ApplicationController
  layout "standard"
  before_filter :login_required
  
  def list
    assigns[:events] = Event.find(:all, :order => :date)
    assigns[:page_title] = _("Upcoming events")
  end

  def new
    assigns[:page_title] = _("Add event")
  end

  def edit
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
