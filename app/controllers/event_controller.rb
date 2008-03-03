class EventController < ApplicationController
  layout "standard"
  before_filter :login_required
  
  def list
    assigns[:events] = Event.find :all, :order => :date
    assigns[:page_title] = _("Upcoming events")
  end

  def new
  end

  def edit
  end
end
